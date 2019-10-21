defmodule Appsignal.Ecto do
  @moduledoc """
  Integration for logging Ecto queries

  If you're using Ecto 3, attach `Appsignal.Ecto` to Telemetry query events in
  your application's `start/2` function:

  ```
  :telemetry.attach(
    "appsignal-ecto",
    [:my_app, :repo, :query],
    &Appsignal.Ecto.handle_event/4,
    nil
  )
  ```

  For versions of Telemetry < 0.3.0, you'll need to call it slightly
  differently:

  ```
  Telemetry.attach(
    "appsignal-ecto",
    [:my_app, :repo, :query],
    Appsignal.Ecto,
    :handle_event,
    nil
  )
  ```

  On Ecto 2, add the `Appsignal.Ecto` module to your Repo's logger
  configuration instead. The `Ecto.LogEntry` logger is the default logger for
  Ecto and needs to be set as well to keep the original Ecto logger behavior
  intact.

  ```
  config :my_app, MyApp.Repo,
    loggers: [Appsignal.Ecto, Ecto.LogEntry]
  ```
  """

  require Logger

  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  def handle_event(_event, event_data, metadata, _config) do
    do_handle_event(transaction(), event_data, metadata)
  end

  def log(entry) do
    do_log(transaction(), entry)
  end

  defp transaction do
    Appsignal.Transaction.lookup(self())
  end

  defp do_handle_event(%Appsignal.Transaction{} = transaction, %{total_time: duration}, metadata) do
    @transaction.record_event(
      transaction,
      "query.ecto",
      "",
      metadata.query,
      convert_time_unit(duration),
      1
    )
  end

  defp do_handle_event(%Appsignal.Transaction{} = transaction, duration, metadata)
       when is_integer(duration) do
    @transaction.record_event(
      transaction,
      "query.ecto",
      "",
      metadata.query,
      convert_time_unit(duration),
      1
    )
  end

  defp do_handle_event(_transaction, _duration, _metadata), do: nil

  defp do_log(%Appsignal.Transaction{} = transaction, entry) do
    duration = (entry.queue_time || 0) + (entry.query_time || 0) + (entry.decode_time || 0)

    @transaction.record_event(
      transaction,
      "query.ecto",
      "",
      entry.query,
      convert_time_unit(duration),
      1
    )

    entry
  end

  defp do_log(_transaction, _entry), do: nil

  defp convert_time_unit(time) do
    # Converts the native time to a value in nanoseconds.
    System.convert_time_unit(time, :native, 1_000_000_000)
  end
end
