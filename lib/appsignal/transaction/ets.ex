defmodule Appsignal.Transaction.ETS do
  use Agent

  @name __MODULE__
  @table :"$appsignal_transaction_registry"

  def start_link do
    Agent.start_link(
      fn ->
        :ets.new(@table, [:set, :named_table, {:keypos, 1}, :public, {:write_concurrency, true}])
      end,
      name: @name
    )
  end

  def insert(value), do: :ets.insert(@table, value)

  def lookup(pid), do: :ets.lookup(@table, pid)

  def match(pattern), do: :ets.match(@table, pattern)

  def delete(pid), do: :ets.delete(@table, pid)
end
