defmodule Appsignal.Transaction.ETS do
  # When support for Elixir 1.4 is dropped, please uncomment the below code. The
  # `Agent.__using__/1` implements a simple `child_spec` as a permanent process
  # and states to use the `__MODULE__.start_link/1` function.
  #
  # use Agent, restart: :permanent

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
