defmodule Appsignal.Ecto do
  @moduledoc """
  Integration for logging Ecto queries

  To add query logging, add the following to you Repo configuration in `config.exs`:

  ```
  config :my_app, MyApp.Repo,
    loggers: [Appsignal.Ecto, Ecto.LogEntry]
  ```

  On Ecto 3, attach Appsignal.Ecto to Telemetry query events in your
  application's start/2 function:

  ```
  Telemetry.attach(
    "appsignal-ecto",
    [:my_app, :repo, :query],
    Appsignal.Ecto,
    :handle_event,
    nil
  )
  ```
  """

  require Logger

  alias Appsignal.{Transaction, TransactionRegistry}

  @nano_seconds :erlang.convert_time_unit(1, :nano_seconds, :native)

  def handle_event(_event, _latency, metadata, _config) do
    log(metadata)
  end

  def log(entry) do
    Logger.debug("AppSignal.Ecto log: #{inspect(entry)}")
    # See if we have a transaction registered for the current process
    case TransactionRegistry.lookup(self()) do
      nil ->
        Logger.debug(
          "AppSignal.Ecto log: Skipping event. No transaction found for #{inspect(self())}"
        )

        # skip
        :ok

      %Transaction{} = transaction ->
        # record the event
        total_time = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
        duration = trunc(total_time / @nano_seconds)

        Logger.debug(
          "AppSignal.Ecto log: recording event for #{inspect(transaction.id)}: #{
            inspect(entry.query)
          }, duration: #{inspect(duration)}"
        )

        Transaction.record_event(transaction, "query.ecto", "", entry.query, duration, 1)
    end

    entry
  end
end
