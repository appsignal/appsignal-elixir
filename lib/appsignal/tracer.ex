defmodule Appsignal.Tracer do
  alias Appsignal.Span

  require Appsignal.Utils

  @monitor Appsignal.Utils.compile_env(:appsignal, :appsignal_monitor, Appsignal.Monitor)
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

    if running?() && !ignored?(pid) do
      span =
        case Keyword.get(options, :start_time) do
          nil -> Span.create_root(namespace, pid)
          timestamp -> Span.create_root(namespace, pid, timestamp)
        end

      register(span)
    end
  end

  def create_span(_namespace, parent, options) do
    pid = Keyword.get(options, :pid, self())

    if running?() && !ignored?(pid) do
      span =
        case Keyword.get(options, :start_time) do
          nil -> Span.create_child(parent, pid)
          timestamp -> Span.create_child(parent, pid, timestamp)
        end

      register(span)
    end
  end

  @doc """
  Finds the span in the registry table.
  """
  @spec lookup(pid()) :: list()
  def lookup(pid) do
    if running?(), do: :ets.lookup(@table, pid)
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

  @spec set_tags(map()) :: nil
  @doc """
  Sets tags for the root span. Previously set tags are overriden.

  ## Example
      Appsignal.Tracer.set_tags(%{"id" => 123})

  """
  def set_tags(value) when is_map(value) do
    Span.do_set_sample_data(root_span(), "tags", value)
    nil
  end

  def set_tags(_value), do: nil

  @spec set_params(map()) :: nil
  @doc """
  Sets request parameters for the root span. Previously set request
  parameters are overriden.

  ## Example
      Appsignal.Tracer.set_params(%{"id" => 123})

  """
  def set_params(value) when is_map(value) do
    Span.do_set_sample_data(root_span(), "params", value)
    nil
  end

  def set_params(_value), do: nil

  @spec set_environment(map()) :: nil
  @doc """
  Sets the request environment data for the root span. This usually
  includes the request headers. Previously set request environment
  data is overriden.

  ## Example
      Appsignal.Tracer.set_environment(%{"req_headers.x-request-id" => "a1b2c3"})

  """
  def set_environment(value) when is_map(value) do
    Span.do_set_sample_data(root_span(), "environment", value)
    nil
  end

  def set_environment(_value), do: nil

  @spec set_session_data(map()) :: nil
  @doc """
  Sets session data for the root span. Previously set session data
  is overriden.

  ## Example
      Appsignal.Tracer.set_session_data(%{"admin" => false})

  """
  def set_session_data(value) when is_map(value) do
    Span.do_set_sample_data(root_span(), "session_data", value)
    nil
  end

  def set_session_data(_value), do: nil

  @spec set_custom_data(map()) :: nil
  @doc """
  Sets custom data for the root span. Previously set custom data
  is overriden.

  ## Example
      Appsignal.Tracer.set_custom_data(%{"locale" => "en_GB"})

  """
  def set_custom_data(value) when is_map(value) do
    Span.do_set_sample_data(root_span(), "custom_data", value)
    nil
  end

  def set_custom_data(_value), do: nil

  @spec close_span(Span.t() | nil) :: :ok | nil
  @doc """
  Closes a span and deregisters it.

  ## Example
      Appsignal.Tracer.current_span()
      |> Appsignal.Tracer.close_span()

  """
  def close_span(%Span{} = span) do
    if running?() do
      span
      |> Span.close()
      |> deregister()
    end

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
    if running?() do
      span
      |> Span.close(end_time)
      |> deregister()
    end

    :ok
  end

  def close_span(nil, _options), do: nil

  @doc """
  Ignores the current process.
  """
  @spec ignore() :: :ok | nil
  def ignore do
    if running?() do
      pid = self()

      delete(pid)
      :ets.insert(@table, {pid, :ignore})
      @monitor.add()
    end

    :ok
  end

  @doc """
  Removes the process' spans from the registry.
  """
  @spec delete(pid()) :: :ok
  def delete(pid) do
    if running?(), do: :ets.delete(@table, pid)
    :ok
  end

  defp register(%Span{pid: pid} = span) do
    :ets.insert(@table, {pid, span})
    @monitor.add()
    span
  end

  defp register(nil), do: nil

  defp deregister(%Span{pid: pid} = span) do
    :ets.delete_object(@table, {pid, span})
  end

  defp ignored?(pid) when is_pid(pid) do
    pid
    |> lookup()
    |> ignored?()
  end

  defp ignored?([{_pid, :ignore}]), do: true
  defp ignored?(_), do: false

  defp running? do
    is_pid(Process.whereis(__MODULE__))
  end
end
