defmodule Appsignal.Span.Registry do
  alias Appsignal.Span

  @name __MODULE__
  @table :"$appsignal_span_registry"

  def start_link do
    Agent.start_link(
      fn ->
        :ets.new(@table, [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])
      end,
      name: @name
    )
  end

  def lookup() do
    lookup(self())
  end

  def lookup(pid) do
    case :ets.lookup(@table, pid) do
      [{pid, %Span{} = span}] -> span
      _ -> nil
    end
  end

  def insert(span) do
    insert(self(), span)
  end

  def insert(pid, %Span{} = span) do
    :ets.insert(@table, {pid, span})
  end

  def delete() do
    :ets.delete(@table, self())
  end
end
