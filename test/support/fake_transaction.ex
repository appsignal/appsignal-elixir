defmodule Appsignal.FakeTransaction do
  @behaviour Appsignal.TransactionBehaviour

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end
  
  def start_event do
    Appsignal.Transaction.start_event
  end

  def finish_event(transaction, name, title, body, body_format) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :finished_events, fn(current) -> 
        finished_event = %{
          transaction: transaction,
          name: name,
          title: title,
          body: body,
          body_format: body_format
        }

        case current do
          nil -> {nil, [finished_event]}
          _ -> {current, [finished_event|current]}
        end
      end)

      new_state
    end)
  end

  def finished_events do
    Agent.get(__MODULE__, &Map.get(&1, :finished_events, []))
  end

  def set_action(_transaction, conn), do: set_action(conn)
  def set_action(action) do
    Agent.update(__MODULE__, &Map.put(&1, :action, action))
  end

  def action do
    Agent.get(__MODULE__, &Map.get(&1, :action))
  end

  def finish, do: self() |> Appsignal.TransactionRegistry.lookup |> finish
  def finish(transaction) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :finished_transactions, fn(current) -> 
        case current do
          nil -> {nil, [transaction]}
          _ -> {current, [transaction|current]}
        end
      end)

      new_state
    end)

    Agent.get(__MODULE__, &Map.get(&1, :finish, :sample))
  end

  def set_finish(result) do
    Agent.update(__MODULE__, &Map.put(&1, :finish, result))
  end

  def finished_transactions do
    Agent.get(__MODULE__, &Map.get(&1, :finished_transactions, []))
  end

  def set_request_metadata(_transation, conn) do
    Agent.update(__MODULE__, &Map.put(&1, :request_metadata, conn))
  end

  def request_metadata do
    Agent.get(__MODULE__, &Map.get(&1, :request_metadata))
  end

  def complete, do: self() |> Appsignal.TransactionRegistry.lookup |> complete
  def complete(transaction) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :completed_transactions, fn(current) -> 
        case current do
          nil -> {nil, [transaction]}
          _ -> {current, [transaction|current]}
        end
      end)

      new_state
    end)

    :ok
  end

  def completed_transactions do
    Agent.get(__MODULE__, &Map.get(&1, :completed_transactions, []))
  end

  def start(id, namespace) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :started_transactions, fn(current) ->
        case current do
          nil -> {nil, [{id, namespace}]}
          _ -> {current, [{id, namespace}|current]}
        end
      end)

      new_state
    end)

    Appsignal.Transaction.start(id, namespace)
  end

  def started_transactions do
    Agent.get(__MODULE__, &Map.get(&1, :started_transactions, []))
  end

  def started_transaction? do
    started_transactions() |> Enum.any?
  end

  def generate_id do
    "123"
  end

  def set_error(transaction, reason, message, stack) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :errors, fn(current) ->
        error = {transaction, reason, message, stack}
        case current do
          nil -> {nil, [error]}
          _ -> {current, [error|current]}
        end
      end)

      new_state
    end)
    transaction
  end

  def errors do
    Agent.get(__MODULE__, &Map.get(&1, :errors, []))
  end
end
