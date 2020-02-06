defmodule Appsignal.Tracer do
  alias Appsignal.{Span}

  @nif Application.get_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)
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
    {:ok, reference} = @nif.create_root_span(name)

    register(%Span{reference: reference}, pid)
  end

  def create_span(name, parent, pid) do
    {:ok, trace_id} = Span.trace_id(parent)
    {:ok, span_id} = Span.span_id(parent)
    {:ok, reference} = @nif.create_child_span(name, trace_id, span_id)

    register(%Span{reference: reference}, pid)
  end

  @doc """
  Returns the current span.
  """
  @spec current_span() :: Span.t() | nil
  def current_span do
    case :ets.lookup(@table, self()) do
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
  def close_span(span), do: close_span(span, self())

  @doc """
  Closes a span and deregisters it from the passed pid.
  """
  @spec close_span(Span.t() | nil, pid()) :: :ok | nil
  def close_span(%Span{reference: reference} = span, pid) do
    :ok = @nif.close_span(reference)
    deregister(span, pid)
    :ok
  end

  def close_span(nil, _pid), do: nil

  defp register(span, pid) do
    :ets.insert(@table, {pid, span})
    span
  end

  defp deregister(span, pid) do
    :ets.delete_object(@table, {pid, span})
  end
end
