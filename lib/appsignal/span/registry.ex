defmodule Appsignal.Span.Registry do
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
    :ets.lookup(@table, pid)
  end

  def insert(trace_id, span_id) do
    insert(self(), trace_id, span_id)
  end

  def insert(pid, trace_id, span_id) do
    :ets.insert(@table, {pid, trace_id, span_id})
  end

  def delete() do
    :ets.delete(@table, self())
  end
end
