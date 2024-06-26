defmodule Appsignal.Tracer do
  alias Appsignal.Span

  @monitor Application.compile_env(:appsignal, :appsignal_monitor, Appsignal.Monitor)

  @table :"$appsignal_registry"

  @type option :: {:pid, pid} | {:start_time, integer}
  @type options :: [option]

  @doc false
  def start_link do
    Agent.start_link(fn -> :ets.new(@table, [:named_table, :public, :duplicate_bag]) end,
      name: __MODULE__
    )
  end

  @doc """
  Creates a new root span.

  ## Example
      Appsignal.Tracer.create_span("http_request")

  """
  @spec create_span(String.t()) :: Span.t() | nil
  def create_span(namespace), do: create_span(namespace, nil, [])

  @doc """
  Creates a new child span.

  ## Example
      parent = Appsignal.Tracer.current_span()

      Appsignal.Tracer.create_span("http_request", parent)
  """
  @spec create_span(String.t(), Span.t() | nil) :: Span.t() | nil
  def create_span(namespace, parent), do: create_span(namespace, parent, [])

  @doc """
  Creates a new span, with an optional parent or pid.

  ## Example
      parent = Appsignal.Tracer.current_span()

      Appsignal.Tracer.create_span("http_request", parent, [start_time: :os.system_time(), pid: self()])
  """
  @spec create_span(String.t(), Span.t() | nil, options) :: Span.t() | nil
  def create_span(namespace, nil, options) do
    pid = Keyword.get(options, :pid, self())

    unless ignored?(pid) do
      namespace
      |> Span.create_root(pid, options[:start_time])
      |> register()
      |> on_create_span()
    end
  end

  def create_span(_namespace, parent, options) do
    pid = Keyword.get(options, :pid, self())

    unless ignored?(pid) do
      parent
      |> Span.create_child(pid, options[:start_time])
      |> register()
      |> on_create_span()
    end
  end

  @doc """
  Finds the span in the registry table.
  """
  @spec lookup(pid()) :: list() | []
  def lookup(pid) do
    try do
      :ets.lookup(@table, pid)
    rescue
      ArgumentError -> []
    end
  end

  @doc """
  Returns the current span in the current process.
  """
  @spec current_span() :: Span.t() | nil
  def current_span, do: current_span(self())

  @doc """
  Returns the current span in the passed pid's process.
  """
  @spec current_span(pid()) :: Span.t() | nil
  def current_span(pid) do
    pid
    |> lookup()
    |> current()
  end

  @doc """
  Returns the root span in the current process.
  """
  @spec root_span() :: Span.t() | nil
  def root_span, do: root_span(self())

  @doc """
  Returns the root span in the passed pid's process.
  """
  @spec root_span(pid()) :: Span.t() | nil
  def root_span(pid) do
    pid
    |> lookup()
    |> root()
  end

  @doc false
  def child_spec(_) do
    %{
      id: Appsignal.Tracer,
      start: {Appsignal.Tracer, :start_link, []}
    }
  end

  defp current({_pid, :ignore}), do: nil

  defp current({_pid, span}), do: span

  defp current(spans) when is_list(spans) do
    spans
    |> List.last()
    |> current()
  end

  defp current(_), do: nil

  defp root([{_pid, %Span{} = root} | _]), do: root

  defp root(_), do: nil

  @spec close_span(Span.t() | nil) :: :ok | nil
  @doc """
  Closes a span and deregisters it.

  ## Example
      Appsignal.Tracer.current_span()
      |> Appsignal.Tracer.close_span()

  """
  def close_span(%Span{} = span) do
    span
    |> Span.close()
    |> deregister()

    :ok
  end

  def close_span(nil), do: nil

  @spec close_span(Span.t() | nil, list()) :: :ok | nil
  @doc """
  Closes a span and deregisters it. Takes an options list, which currently only
  accepts a `List` with an `:end_time` integer.

  ## Example
      Appsignal.Tracer.current_span()
      |> Appsignal.Tracer.close_span(end_time: :os.system_time())

  """
  def close_span(span, options)

  def close_span(%Span{} = span, end_time: end_time) do
    span
    |> Span.close(end_time)
    |> deregister()

    :ok
  end

  def close_span(nil, _options), do: nil

  @doc """
  Ignores the given process.
  """
  @spec ignore(pid()) :: :ok
  def ignore(pid) do
    delete(pid)
    insert({pid, :ignore}) && @monitor.add()
    :ok
  end

  @doc """
  Ignores the current process.
  """
  @spec ignore() :: :ok
  def ignore do
    self() |> ignore()
  end

  @doc """
  Removes the process' spans from the registry.
  """
  @spec delete(pid()) :: :ok
  def delete(pid) do
    try do
      :ets.delete(@table, pid)
    rescue
      ArgumentError -> :ok
    end

    :ok
  end

  @doc false
  def register_current(span) do
    # Registers a span as the current span for this process.
    #
    # This is necessary when you want to instrument asynchronous work.
    #
    #     parent = Appsignal.Tracer.current_span()
    #
    #     list
    #     |> Task.async_stream(fn item ->
    #       Appsignal.Tracer.register_current(parent)
    #       # ...
    #     end)
    #     |> Stream.run()

    register(%{span | pid: self()})
  end

  defp register(%Span{pid: pid} = span) do
    if insert({pid, span}) do
      @monitor.add()
      span
    end
  end

  defp register(nil), do: nil

  defp deregister(%Span{pid: pid} = span) do
    try do
      :ets.delete_object(@table, {pid, span})
    rescue
      ArgumentError -> false
    end
  end

  defp ignored?(pid) when is_pid(pid) do
    pid
    |> lookup()
    |> ignored?()
  end

  defp ignored?([{_pid, :ignore}]), do: true
  defp ignored?(_), do: false

  defp insert(span) do
    try do
      :ets.insert(@table, span)
    rescue
      ArgumentError -> nil
    end
  end

  @spec on_create_span(Span.t() | nil) :: Span.t() | nil
  defp on_create_span(span) do
    custom_on_create_fun =
      Application.get_env(:appsignal, :custom_on_create_fun, &__MODULE__.custom_on_create_fun/1)

    custom_on_create_fun.(span)
    span
  end

  @doc """
  This function can be defined by the user and will be executed on the
  creation of the span after create_span/3 is executed. It can be used to add
  custom_data to the span.

  Example in your own application:
  ```ex
  defmodule MyApp.Appsignal do
    def custom_on_create_fun(span) do
      Appsignal.Span.set_sample_data(span, "custom_data", %{"foo": "bar"})
    end
  end
  ```

  This can be added to the config with:
  ```ex
  config :appsignal, custom_on_create_fun: &MyApp.Appsignal.custom_on_create_fun/1
  ```
  """

  @spec custom_on_create_fun(Span.t() | nil) :: any()
  def custom_on_create_fun(_span) do
    nil
  end
end
