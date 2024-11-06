defmodule Appsignal do
  @moduledoc """
  AppSignal for Elixir. Follow the [installation
  guide](https://docs.appsignal.com/elixir/installation.html) to install
  AppSignal into your Elixir app.

  This module contains the main AppSignal OTP application, as well as a few
  helper functions for sending metrics to AppSignal.
  """

  @os Application.compile_env(:appsignal, :os_internal, :os)

  use Application
  alias Appsignal.Config
  require Logger

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    initialize()

    if Config.error_backend_enabled?() do
      Appsignal.Error.Backend.attach()
    end

    if Config.instrument_ecto?() do
      Appsignal.Ecto.attach()
    end

    if Config.instrument_finch?() do
      Appsignal.Finch.attach()
    end

    if Config.instrument_oban?() do
      Appsignal.Oban.attach()
    end

    if Config.instrument_tesla?() do
      Appsignal.Tesla.attach()
    end

    if Config.instrument_absinthe?() do
      Appsignal.Absinthe.attach()
    end

    children = [
      {Appsignal.Tracer, []},
      {Appsignal.Monitor, []},
      {Appsignal.Probes, []},
      {Appsignal.CheckIn.Scheduler, []},
      :hackney_pool.child_spec(:appsignal_transmitter, [])
    ]

    result = Supervisor.start_link(children, strategy: :one_for_one, name: Appsignal.Supervisor)

    # Add our default system probes. It's important that this is called after
    # the Suportvisor has started. Otherwise the GenServer cannot register the
    # probe.
    add_default_probes()

    result
  end

  @doc false
  def stop(_state) do
    Appsignal.IntegrationLogger.debug("AppSignal stopping.")
  end

  @doc false
  def config_change(_changed, _new, _removed) do
    # Spawn a separate process that reloads the configuration. AppSignal can't
    # reload it in the same process because the GenServer would continue
    # calling itself once it reached `Application.put_env` in
    # `Appsignal.Config`.
    spawn(fn ->
      Appsignal.Nif.stop()
      initialize()
    end)

    :ok
  end

  @doc false
  @spec initialize() :: :ok
  def initialize do
    case {Config.initialize(), Config.configured_as_active?()} do
      {_, false} ->
        Logger.info("AppSignal disabled.")

      {:ok, true} ->
        Appsignal.IntegrationLogger.debug("AppSignal starting.")
        Config.write_to_environment()
        Appsignal.Nif.start()

        if Appsignal.Nif.loaded?() do
          Appsignal.IntegrationLogger.debug("AppSignal started.")
        else
          log_nif_loading_error()
        end

      {{:error, :invalid_config}, true} ->
        Logger.warning(
          "Warning: No valid AppSignal configuration found, continuing with " <>
            "AppSignal metrics disabled."
        )
    end
  end

  @doc false
  def add_default_probes do
    # This is a workaround for https://github.com/erlang/otp/issues/5425.
    :erlang.system_flag(:scheduler_wall_time, true)

    Appsignal.Probes.register(:erlang, &Appsignal.Probes.ErlangProbe.call/1)
  end

  @doc """
  Set a gauge for a measurement of a metric.
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
  Increment a counter of a metric.
  """
  @spec increment_counter(String.t(), number, map) :: :ok
  def increment_counter(key, count \\ 1, tags \\ %{})

  def increment_counter(key, count, %{} = tags) when is_number(count) do
    encoded_tags = Appsignal.Utils.DataEncoder.encode(tags)
    :ok = Appsignal.Nif.increment_counter(key, count + 0.0, encoded_tags)
  end

  @doc """
  Add a value to a distribution

  Use this to collect multiple data points that will be merged into a graph.
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

  defdelegate instrument(fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, category, fun), to: Appsignal.Instrumentation
  defdelegate set_error(exception, stacktrace), to: Appsignal.Instrumentation
  defdelegate set_error(kind, reason, stacktrace), to: Appsignal.Instrumentation
  defdelegate send_error(exception, stacktrace), to: Appsignal.Instrumentation
  defdelegate send_error(kind, reason, stacktrace), to: Appsignal.Instrumentation
  defdelegate send_error(kind, reason, stacktrace, fun), to: Appsignal.Instrumentation

  @spec heartbeat(String.t()) :: :ok
  @deprecated "Use `Appsignal.CheckIn.cron/1` instead."
  defdelegate heartbeat(name), to: Appsignal.CheckIn, as: :cron

  @spec heartbeat(String.t(), (-> out)) :: out when out: var
  @deprecated "Use `Appsignal.CheckIn.cron/2` instead."
  defdelegate heartbeat(name, fun), to: Appsignal.CheckIn, as: :cron

  defp log_nif_loading_error do
    arch = parse_architecture(to_string(:erlang.system_info(:system_architecture)))
    {_, target_list} = @os.type()
    target = to_string(target_list)
    {install_arch, install_target} = fetch_installed_architecture_target()

    if arch == install_arch && target == install_target do
      Appsignal.IntegrationLogger.error(
        "AppSignal failed to load the extension. Please run the diagnose tool and email us at support@appsignal.com: https://docs.appsignal.com/elixir/command-line/diagnose.html\n",
        stderr: true
      )
    else
      Appsignal.IntegrationLogger.error(
        "The AppSignal NIF was installed for architecture '#{install_arch}-#{install_target}', but the current architecture is '#{arch}-#{target}'. Please reinstall the AppSignal package on the host the app is started: mix deps.compile appsignal --force",
        stderr: true
      )
    end
  end

  # Parse install report and fetch the architecture and target
  defp fetch_installed_architecture_target do
    case File.read(Path.join([:code.priv_dir(:appsignal), "install.report"])) do
      {:ok, raw_report} ->
        case Jason.decode(raw_report) do
          {:ok, report} ->
            %{"build" => %{"architecture" => arch, "target" => target}} = report
            {parse_architecture(arch), target}

          {:error, reason} ->
            Appsignal.IntegrationLogger.error(
              "Failed to parse the AppSignal 'install.report' file: #{inspect(reason)}",
              stderr: true
            )

            {"unknown", "unknown"}
        end

      {:error, reason} ->
        Appsignal.IntegrationLogger.error(
          "Failed to read the AppSignal 'install.report' file: #{inspect(reason)}",
          stderr: true
        )

        {"unknown", "unknown"}
    end
  end

  # Transform `aarch64-apple-darwin21.3.0` to `aarch64`
  defp parse_architecture(arch_parts) do
    List.first(String.split(arch_parts, "-", parts: 2))
  end
end
