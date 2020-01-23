defmodule Appsignal.Tracer do
  alias Appsignal.{Span, Nif}

  @table :"$appsignal_registry"

  def start_link do
    Agent.start_link(fn -> :ets.new(@table, [:named_table, :public]) end)
  end

  @doc """
  Creates a new span.
  """
  @spec create_span(String.t()) :: Span.t()
  def create_span(name) do
    {:ok, reference} = Nif.create_root_span(name)
    register(%Span{reference: reference})
  end

  @doc """
  Returns the current span.
  """
  @spec current_span() :: Span.t() | nil
  def current_span do
    case :ets.lookup(@table, self()) do
      [{_pid, span} | _] -> span
      [] -> nil
    end
  end

  defp register(span) do
    :ets.insert(@table, {self(), span})
    span
  end
end
