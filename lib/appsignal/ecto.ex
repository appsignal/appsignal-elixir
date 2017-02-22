defmodule Appsignal.Ecto do
  @moduledoc """
  Integration for logging Ecto queries

  To add query logging, add the following to you Repo configuration in `config.exs`:

  ```
  config :my_app, MyApp.Repo,
    loggers: [Appsignal.Ecto]
  ```

  """

  require Logger

  alias Appsignal.{Transaction, TransactionRegistry}

  @nano_seconds :erlang.convert_time_unit(1, :nano_seconds, :native)

  def log(entry) do

    # See if we have a transaction registered for the current process
    case TransactionRegistry.lookup(self()) do
      nil ->
        # skip
        :ok
      %Transaction{} = transaction ->
        # record the event
        total_time = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
        duration = trunc(total_time / @nano_seconds)
        Transaction.record_event(transaction, "query.ecto", "", entry.query, duration, 1)
    end
    entry
  end

end
