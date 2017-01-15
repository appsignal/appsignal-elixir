defmodule Appsignal do
  @moduledoc """
  Main library entrypoint.

  This module contains the main Appsignal OTP application, as well as
  a few helper functions for sending metrics to Appsignal.

  These metrics do not rely on an active transaction being
  present. For transaction related-functions, see the
  [Appsignal.Transaction](Appsignal.Transaction.html) module.

  """

  use Application

  alias Appsignal.Config

  require Logger

  @doc """
  Application callback function
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    initialize()

    :error_logger.add_report_handler(Appsignal.ErrorHandler)

    children = [
      worker(Appsignal.TransactionRegistry, [])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Appsignal.Supervisor])
  end

  def started? do
    Application.get_application(Appsignal) != nil
  end

  @doc """
  Application callback function
  """
  def stop(_state) do
    Logger.debug("Appsignal stopping.")
  end

  def config_change(_changed, _new, _removed) do
    :ok = Appsignal.Nif.stop()
    :ok = initialize()
  end

  defp initialize() do
    case {Config.initialize, Config.active?} do
      {:ok, true} ->
        Logger.debug("Appsignal starting.")
        Appsignal.Nif.start()
      {:ok, false} ->
        Logger.info("Appsignal disabled.")
        :ok
      {{:error, :invalid_config}, _} ->
        # show warning that Appsignal is not configured; but not when we run the tests.
        spawn_link(fn ->
          :timer.sleep 100 # FIXME, this timeout is kind of cludgy.
          unless Process.whereis(ExUnit.Server) do
            Logger.warn("Warning: No valid Appsignal configuration found, continuing with Appsignal metrics disabled.")
          end
        end)
        :ok
    end
  end


  @doc """
  Set a gauge for a measurement of some metric.
  """
  @spec set_gauge(String.t, float | integer) :: :ok
  def set_gauge(key, value) when is_integer(value) do
    set_gauge(key, value + 0.0)
  end
  def set_gauge(key, value) when is_float(value) do
    Appsignal.Nif.set_gauge(key, value)
  end

  @doc """
  Increment a counter of some metric.
  """
  @spec increment_counter(String.t, integer) :: :ok
  def increment_counter(key, count \\ 1) when is_integer(count) do
    Appsignal.Nif.increment_counter(key, count)
  end

  @doc """
  Add a value to a distribution

  Use this to collect multiple data points that will be merged into a
  graph.
  """
  @spec add_distribution_value(String.t, float | integer) :: :ok
  def add_distribution_value(key, value) when is_integer(value) do
    add_distribution_value(key, value + 0.0)
  end
  def add_distribution_value(key, value) when is_float(value) do
    Appsignal.Nif.add_distribution_value(key, value)
  end


  @doc """
  Send an error to Appsignal

  When there is no current transaction, this call starts one.

  """
  def send_error(reason, message \\ "", stack \\ nil, metadata \\ %{}, conn \\ nil) do
    stack = stack || System.stacktrace()
    transaction = Appsignal.Transaction.lookup_or_create_transaction(self())
    if transaction != nil do
      {reason, message} = Appsignal.ErrorHandler.extract_reason_and_message(reason, message)
      Appsignal.ErrorHandler.submit_transaction(transaction, reason, message, stack, metadata, conn)
    end
  end

end
