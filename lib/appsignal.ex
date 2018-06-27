defmodule Appsignal do
  @moduledoc """
  AppSignal for Elixir. Follow the [installation guide](https://docs.appsignal.com/elixir/installation.html) to install AppSignal into your Elixir app.

  This module contains the main AppSignal OTP application, as well as
  a few helper functions for sending metrics to AppSignal.

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

  def plug? do
    Code.ensure_loaded?(Plug)
  end

  def phoenix? do
    Code.ensure_loaded?(Phoenix)
  end

  @doc """
  Application callback function
  """
  def stop(_state) do
    Logger.debug("AppSignal stopping.")
  end

  def config_change(_changed, _new, _removed) do
    # Spawn a separate process that reloads the configuration. AppSignal can't
    # reload it in the same process because the GenServer would continue
    # calling itself once it reached `Application.put_env` in
    # `Appsignal.Config`.
    spawn(fn ->
      :ok = Appsignal.Nif.stop()
      :ok = initialize()
    end)
  end

  @doc false
  def initialize() do
    case {Config.initialize(), Config.configured_as_active?()} do
      {_, false} ->
        Logger.info("AppSignal disabled.")

      {:ok, true} ->
        Logger.debug("AppSignal starting.")
        Config.write_to_environment()
        Appsignal.Nif.start()

        if Appsignal.Nif.loaded?() do
          Logger.debug("AppSignal started.")
        else
          Logger.error(
            "Failed to start AppSignal. Please run the diagnose task " <>
              "(https://docs.appsignal.com/elixir/command-line/diagnose.html) " <>
              "to debug your installation."
          )
        end

      {{:error, :invalid_config}, true} ->
        Logger.warn(
          "Warning: No valid AppSignal configuration found, continuing with " <>
            "AppSignal metrics disabled."
        )
    end
  end

  @doc """
  Set a gauge for a measurement of some metric.
  """
  @spec set_gauge(String.t(), float | integer, map) :: :ok
  def set_gauge(key, value, tags \\ %{})

  def set_gauge(key, value, tags) when is_integer(value) do
    set_gauge(key, value + 0.0, tags)
  end

  def set_gauge(key, value, %{} = tags) when is_float(value) do
    encoded_tags = Appsignal.Utils.DataEncoder.encode(tags)
    :ok = Appsignal.Nif.set_gauge(key, value, encoded_tags)
  end

  @doc """
  Increment a counter of some metric.
  """
  @spec increment_counter(String.t(), integer, map) :: :ok
  def increment_counter(key, count \\ 1, %{} = tags \\ %{}) when is_integer(count) do
    encoded_tags = Appsignal.Utils.DataEncoder.encode(tags)
    :ok = Appsignal.Nif.increment_counter(key, count, encoded_tags)
  end

  @doc """
  Add a value to a distribution

  Use this to collect multiple data points that will be merged into a
  graph.
  """
  @spec add_distribution_value(String.t(), float | integer, map) :: :ok
  def add_distribution_value(key, value, tags \\ %{})

  def add_distribution_value(key, value, tags) when is_integer(value) do
    add_distribution_value(key, value + 0.0, tags)
  end

  def add_distribution_value(key, value, %{} = tags) when is_float(value) do
    encoded_tags = Appsignal.Utils.DataEncoder.encode(tags)
    :ok = Appsignal.Nif.add_distribution_value(key, value, encoded_tags)
  end

  @doc """
  Send an error to AppSignal

  When there is no current transaction, this call starts one.

  ## Examples
      Appsignal.send_error(%RuntimeError{})
      Appsignal.send_error(%RuntimeError{}, "Oops!")
      Appsignal.send_error(%RuntimeError{}, "", System.stacktrace())
      Appsignal.send_error(%RuntimeError{}, "", nil, %{foo: "bar"})
      Appsignal.send_error(%RuntimeError{}, "", nil, %{}, %Plug.Conn{})
      Appsignal.send_error(%RuntimeError{}, "", nil, %{}, nil, fn(transaction) ->
        Appsignal.Transaction.set_sample_data(transaction, "key", %{foo: "bar"})
      end)
  """
  def send_error(reason, message \\ "", stack \\ nil, metadata \\ %{}, conn \\ nil, fun \\ fn(t) -> t end, namespace \\ :http_request) do
    stack = stack || System.stacktrace()

    transaction = Appsignal.Transaction.create("_" <> Appsignal.Transaction.generate_id(), namespace)
    fun.(transaction)
    {reason, message} = Appsignal.ErrorHandler.extract_reason_and_message(reason, message)
    Appsignal.ErrorHandler.submit_transaction(transaction, reason, message, stack, metadata, conn)
  end
end
