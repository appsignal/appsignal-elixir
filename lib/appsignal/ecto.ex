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
  :telemetry.attach(
    "appsignal-ecto",
    [:my_app, :repo, :query],
    &Appsignal.Ecto.handle_event/4,
    nil
  )
  ```

  For versions of Telemetry < 0.3.0, you'll need to call it slightly differently:

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

  def handle_event(_event, _latency, metadata, _config) do
    # @transaction.record_event("query.ecto", "", metadata.query, duration, 1)
    log(metadata)
  end

  def log(entry) do
    total_time = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)
    duration = System.convert_time_unit(total_time, :native, :nanosecond)
    @transaction.record_event("query.ecto", "", entry.query, duration, 1)

    entry
  end
end
