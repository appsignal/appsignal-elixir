defmodule Appsignal.Logger do
  require Appsignal.Utils

  @nif Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)
  @severity %{
    trace: 1,
    debug: 2,
    info: 3,
    warn: 5,
    error: 6
  }

  @type log_level :: :trace | :debug | :info | :warn | :error

  @spec trace(String.t(), String.t(), %{}) :: :ok
  def trace(group, message, metadata \\ %{}) do
    log(:trace, group, message, metadata)
  end

  @spec debug(String.t(), String.t(), %{}) :: :ok
  def debug(group, message, metadata \\ %{}) do
    log(:debug, group, message, metadata)
  end

  @spec info(String.t(), String.t(), %{}) :: :ok
  def info(group, message, metadata \\ %{}) do
    log(:info, group, message, metadata)
  end

  @spec warn(String.t(), String.t(), %{}) :: :ok
  def warn(group, message, metadata \\ %{}) do
    log(:warn, group, message, metadata)
  end

  @spec error(String.t(), String.t(), %{}) :: :ok
  def error(group, message, metadata \\ %{}) do
    log(:error, group, message, metadata)
  end

  @spec log(log_level(), String.t(), String.t(), %{}) :: :ok
  defp log(log_level, group, message, metadata) do
    severity = @severity[log_level]
    encoded_metadata = Appsignal.Utils.DataEncoder.encode(metadata)

    @nif.log(
      group,
      severity,
      message,
      encoded_metadata
    )
  end
end
