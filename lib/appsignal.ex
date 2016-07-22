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

    case {Config.initialize, Config.active?} do
      {:ok, true} ->
        Logger.debug("Appsignal starting.")
        Appsignal.Nif.start
      {:ok, false} ->
        Logger.info("Appsignal disabled.")
      {{:error, :invalid_config}, _} ->
        Logger.warn("Warning: No valid Appsignal configuration found, continuing with Appsignal metrics disabled.")
    end

    :error_logger.add_report_handler(Appsignal.ErrorHandler)

    children = [
      worker(Appsignal.TransactionRegistry, [])
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Appsignal.Supervisor])
  end

  @doc """
  Application callback function
  """
  def stop(_state) do
    Logger.debug("Appsignal stopping.")
  end

  @doc """
  Set a gauge for a measurement of some metric.
  """
  @spec set_gauge(String.t, float) :: :ok
  def set_gauge(key, value) do
    Appsignal.Nif.set_gauge(key, value)
  end

  @doc """
  Increment a counter of some metric.
  """
  @spec increment_counter(String.t, integer) :: :ok
  def increment_counter(key, count \\ 1) do
    Appsignal.Nif.increment_counter(key, count)
  end

  @doc """
  Add a value to a distribution

  Use this to collect multiple data points that will be merged into a
  graph.
  """
  @spec add_distribution_value(String.t, float) :: :ok
  def add_distribution_value(key, value) do
    Appsignal.Nif.add_distribution_value(key, value)
  end

end
