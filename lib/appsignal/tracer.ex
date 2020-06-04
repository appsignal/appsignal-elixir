defmodule Appsignal.Tracer do
  @moduledoc false
  alias Appsignal.Span

  @monitor Application.get_env(:appsignal, :appsignal_monitor, Appsignal.Monitor)
  @table :"$appsignal_registry"

  @type option :: {:pid, pid} | {:start_time, integer}
  @type options :: [option]

  def start_link do
    Agent.start_link(fn -> :ets.new(@table, [:named_table, :public, :duplicate_bag]) end)
  end

  @doc """
  Creates a new root span.
  """
  @spec create_span(String.t()) :: Span.t()
  def create_span(namespace), do: create_span(namespace, nil, [])

  @doc """
  Creates a new child span.
  """
  @spec create_span(String.t(), Span.t() | nil) :: Span.t()
  def create_span(namespace, parent), do: create_span(namespace, parent, [])

  @doc """
  Creates a new span, with an optional parent or pid.
  """
  @spec create_span(String.t(), Span.t() | nil, options) :: Span.t()
  def create_span(namespace, nil, options) do
    pid = Keyword.get(options, :pid, self())

    unless ignored?(pid) do
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

    unless ignored?(pid) do
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
    :ets.lookup(@table, pid)
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
    @table
    |> :ets.lookup(pid)
    |> root()
  end

  defp current([]), do: nil

  defp current([{_pid, :ignore}]), do: nil

  defp current(spans) when is_list(spans) do
    {_pid, span} = List.last(spans)
    span
  end

  defp root([{_pid, %Span{} = root} | _]), do: root

  defp root(_), do: nil

  @doc """
  Closes a span and deregisters it.
  """
  @spec close_span(Span.t() | nil) :: :ok | nil
  def close_span(%Span{} = span) do
    span
    |> Span.close()
    |> deregister()

    :ok
  end

  @spec close_span(Span.t() | nil, end_time: integer) :: :ok | nil
  def close_span(%Span{} = span, end_time: end_time) do
    span
    |> Span.close(end_time)
    |> deregister()

    :ok
  end

  def close_span(nil), do: nil

  @doc """
  Ignores the current process.
  """
  @spec ignore() :: :ok | nil
  def ignore do
    pid = self()

    delete(pid)
    :ets.insert(@table, {pid, :ignore})
    @monitor.add()
    :ok
  end

  @doc """
  Removes the process' spans from the registry.
  """
  @spec delete(pid()) :: :ok
  def delete(pid) do
    :ets.delete(@table, pid)
    :ok
  end

  defp register(%Span{pid: pid} = span) do
    :ets.insert(@table, {pid, span})
    span
  end

  defp register(nil), do: nil

  defp deregister(%Span{pid: pid} = span) do
    :ets.delete_object(@table, {pid, span})
  end

  defp ignored?(pid) when is_pid(pid) do
    @table
    |> :ets.lookup(pid)
    |> ignored?()
  end

  defp ignored?([{_pid, :ignore}]), do: true
  defp ignored?(_), do: false
end
