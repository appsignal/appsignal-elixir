defmodule Appsignal.Tracer do
  require Logger

  alias Appsignal.Span
  alias Appsignal.Tracer.Registry

  @monitor Application.compile_env(:appsignal, :appsignal_monitor, Appsignal.Monitor)

  @type option :: {:pid, pid} | {:start_time, integer}
  @type options :: [option]

  @doc false
  def start_link do
    Agent.start_link(
      fn ->
        Registry.new()
        Appsignal.Error.Reported.new()
      end,
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

    namespace
    |> Span.create_root(pid, options[:start_time])
    |> register(:own, nil, nil)
    |> on_create_span()
  end

  def create_span(_namespace, parent, options) do
    pid = Keyword.get(options, :pid, self())

    parent
    |> Span.create_child(pid, options[:start_time])
    |> register(:own, Registry.trace_root(parent), Registry.anchor(parent, pid))
    |> on_create_span()
  end

  @doc """
  Finds the span in the registry table.
  """
  @spec lookup(pid()) :: list() | []
  def lookup(pid) do
    Registry.lookup(pid)
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
    Registry.current(pid)
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
    Registry.root(pid)
  end

  @doc false
  def child_spec(_) do
    %{
      id: Appsignal.Tracer,
      start: {Appsignal.Tracer, :start_link, []}
    }
  end

  @spec close_span(Span.t() | nil) :: :ok | nil
  @doc """
  Closes a span and deregisters it.

  ## Example
      span = Appsignal.Tracer.create_span("http_request")
      # ...
      Appsignal.Tracer.close_span(span)

  """
  def close_span(%Span{} = span) do
    Span.close(span)
    :ok
  end

  def close_span(nil), do: nil

  @spec close_span(Span.t() | nil, list()) :: :ok | nil
  @doc """
  Closes a span and deregisters it. Takes a keyword list of options, of which
  only `:end_time` is used.

  ## Example
      span = Appsignal.Tracer.create_span("http_request")
      # ...
      Appsignal.Tracer.close_span(span, end_time: :os.system_time())

  """
  def close_span(span, options)

  def close_span(%Span{} = span, options) when is_list(options) do
    close_with(span, options[:end_time])
    :ok
  end

  def close_span(nil, _options), do: nil

  @doc """
  Does nothing. It used to stop the given process from creating spans.
  """
  @deprecated "Use Appsignal.Tracer.ignore/0 in the process whose trace to ignore."
  @spec ignore(pid()) :: :ok
  def ignore(_pid) do
    Logger.warning(
      "Appsignal.Tracer.ignore/1 no longer does anything. " <>
        "Call Appsignal.Tracer.ignore/0 in the process whose trace to ignore."
    )

    :ok
  end

  @doc """
  Ignores the current trace: the trace the current span belongs to is not
  reported. Does nothing when there is no current span.
  """
  @spec ignore() :: :ok
  def ignore do
    case current_span() do
      nil -> :ok
      span -> Span.set_attribute(span, "appsignal.ignore_trace", true)
    end

    :ok
  end

  @doc """
  Removes the process' spans from the registry.
  """
  @spec delete(pid()) :: :ok
  def delete(pid) do
    Registry.delete(pid)
  end

  @doc false
  def close_all(span_or_pid, options \\ [])

  def close_all(%Span{} = span, options) do
    descendants = Registry.descendants(span)

    Enum.each(descendants, fn descendant ->
      Span.set_name_if_nil(descendant, "[unfinished transaction event]")
      close_with(descendant, options[:end_time])
    end)

    close_with(span, options[:end_time])

    if descendants != [] do
      Appsignal.IntegrationLogger.debug(
        "Appsignal.Tracer closed #{length(descendants)} spans left open under a span in #{inspect(span.pid)}"
      )
    end

    :ok
  end

  def close_all(nil, _options), do: nil

  def close_all(pid, options) when is_pid(pid) do
    spans = pid |> Registry.own_spans() |> Enum.reverse()

    Enum.each(spans, fn {span, root?} ->
      unless root?, do: Span.set_name_if_nil(span, "[unfinished transaction event]")
      close_with(span, options[:end_time])
    end)

    if spans != [] do
      Appsignal.IntegrationLogger.debug(
        "Appsignal.Tracer closed #{length(spans)} spans left open in #{inspect(pid)}"
      )
    end

    :ok
  end

  defp close_with(span, nil), do: Span.close(span)
  defp close_with(span, end_time), do: Span.close(span, end_time)

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

    register(%{span | pid: self()}, :attached, Registry.trace_root(span), nil)
  end

  defp register(%Span{} = span, origin, trace_root, anchor) do
    if Registry.insert(span, origin, trace_root, anchor) do
      @monitor.add(span.pid)
      span
    end
  end

  defp register(nil, _origin, _trace_root, _anchor), do: nil

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
