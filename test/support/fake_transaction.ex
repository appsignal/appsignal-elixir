defmodule Appsignal.FakeTransaction do
  @behaviour Appsignal.TransactionBehaviour
  use TestAgent, %{started_transactions: [], finished_events: [], finished_transactions: [], errors: []}

  def start_event, do: Appsignal.Transaction.start_event

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

  def set_action(_transaction, conn), do: set_action(conn)
  def set_action(action) do
    Agent.update(__MODULE__, &Map.put(&1, :action, action))
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

  def set_request_metadata(_transation, conn) do
    Agent.update(__MODULE__, &Map.put(&1, :request_metadata, conn))
  end

  def set_sample_data(transaction, key, payload) do
    Agent.update(__MODULE__, fn(state) ->
      {_, new_state} = Map.get_and_update(state, :sample_data, fn(current) ->
        case current do
          nil -> {nil, %{key => payload}}
          _ -> {current, Map.put(current, key, payload)}
        end
      end)

      new_state
    end)

    transaction
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

  def generate_id, do: "123"

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

  # Convenience methods for testing

  def finished_events(pid_or_module) do
    get(pid_or_module, :finished_events)
  end

  def action(pid_or_module) do
    get(pid_or_module, :action)
  end

  def started_transactions(pid_or_module) do
    get(pid_or_module, :started_transactions)
  end

  def started_transaction?(pid_or_module) do
    started_transactions(pid_or_module) |> Enum.any?
  end

  def finished_transactions(pid_or_module) do
    get(pid_or_module, :finished_transactions)
  end

  def completed_transactions(pid_or_module) do
    get(pid_or_module, :completed_transactions)
  end

  def request_metadata(pid_or_module) do
    get(pid_or_module, :request_metadata)
  end

  def sample_data(pid_or_module) do
    get(pid_or_module, :sample_data)
  end

  def errors(pid_or_module) do
    get(pid_or_module, :errors)
  end
end
