defmodule Appsignal.Span.Registry do
  alias Appsignal.Span

  @table :"$appsignal_span_registry"

  def start_link do
    Agent.start_link(
      fn ->
        :ets.new(@table, [
          :named_table,
          :duplicate_bag,
          :public,
          read_concurrency: true,
          write_concurrency: true
        ])
      end,
      name: __MODULE__
    )
  end

  def lookup() do
    lookup(self())
  end

  def lookup(pid) do
    case :ets.lookup(@table, pid) do
      [{_pid, %Span{} = span}] ->
        span

      [_ | _] = spans ->
        {_pid, span} = List.last(spans)
        span

      _ ->
        nil
    end
  end

  def insert(span) do
    insert(self(), span)
  end

  def insert(pid, %Span{} = span) do
    :ets.insert(@table, {pid, span})
  end

  def delete() do
    pid = self()
    span = lookup(pid)

    :ets.delete_object(@table, {pid, span})
  end
end
