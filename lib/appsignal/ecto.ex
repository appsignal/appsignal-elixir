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

  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)
  @nano_seconds :erlang.convert_time_unit(1, :nano_seconds, :native)

  def handle_event(_event, _latency, metadata, _config) do
    log(metadata)
  end

  def log(entry) do
    total_time = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    duration = trunc(total_time / @nano_seconds)
    @transaction.record_event("query.ecto", "", entry.query, duration, 1)

    entry
  end
end
