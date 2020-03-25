defmodule Appsignal.Tracer do
  alias Appsignal.Span

  @table :"$appsignal_registry"

  def start_link do
    Agent.start_link(fn -> :ets.new(@table, [:named_table, :public, :duplicate_bag]) end)
  end

  @doc """
  Creates a new root span.
  """
  @spec create_span(String.t()) :: Span.t()
  def create_span(name), do: create_span(name, nil, self())

  @doc """
  Creates a new child span.
  """
  @spec create_span(String.t(), Span.t() | nil) :: Span.t()
  def create_span(name, parent), do: create_span(name, parent, self())

  @doc """
  Creates a new span, with an optional parent or pid.
  """
  @spec create_span(String.t(), Span.t() | nil, pid()) :: Span.t()
  def create_span(name, nil, pid) do
    name
    |> Span.create_root(pid)
    |> register()
  end

  def create_span(name, parent, pid) do
    name
    |> Span.create_child(parent, pid)
    |> register()
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
    case :ets.lookup(@table, pid) do
      [] ->
        nil

      spans ->
        {_pid, span} = List.last(spans)
        span
    end
  end

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

  def close_span(nil), do: nil

  @doc """
  Ignores a process.
  """
  @spec ignore(pid()) :: :ok | nil
  def ignore(pid) do
    :ets.delete(@table, pid)
    :ets.insert(@table, {pid, :ignore})
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
end
