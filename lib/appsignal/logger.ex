defmodule Appsignal.Logger do
  require Appsignal.Utils

  @nif Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

  @type log_level ::
          :debug | :info | :notice | :warning | :error | :critical | :alert | :emergency

  @spec debug(String.t(), String.t(), %{}) :: :ok
  def debug(group, message, metadata \\ %{}) do
    log(:debug, group, message, metadata)
  end

  @spec info(String.t(), String.t(), %{}) :: :ok
  def info(group, message, metadata \\ %{}) do
    log(:info, group, message, metadata)
  end

  @spec notice(String.t(), String.t(), %{}) :: :ok
  def notice(group, message, metadata \\ %{}) do
    log(:notice, group, message, metadata)
  end

  @spec warning(String.t(), String.t(), %{}) :: :ok
  def warning(group, message, metadata \\ %{}) do
    log(:warning, group, message, metadata)
  end

  @spec error(String.t(), String.t(), %{}) :: :ok
  def error(group, message, metadata \\ %{}) do
    log(:error, group, message, metadata)
  end

  @spec critical(String.t(), String.t(), %{}) :: :ok
  def critical(group, message, metadata \\ %{}) do
    log(:critical, group, message, metadata)
  end

  @spec alert(String.t(), String.t(), %{}) :: :ok
  def alert(group, message, metadata \\ %{}) do
    log(:alert, group, message, metadata)
  end

  @spec emergency(String.t(), String.t(), %{}) :: :ok
  def emergency(group, message, metadata \\ %{}) do
    log(:emergency, group, message, metadata)
  end

  @spec log(log_level(), String.t(), String.t(), %{}, atom()) :: :ok
  def log(log_level, group, message, metadata, format \\ :plaintext) do
    encoded_metadata = Appsignal.Utils.DataEncoder.encode(metadata)

    @nif.log(group, severity(log_level), format(format), message, encoded_metadata)
  end

  defp severity(:debug), do: 2
  defp severity(:info), do: 3
  defp severity(:notice), do: 4
  defp severity(:warn), do: 5
  defp severity(:warning), do: 5
  defp severity(:error), do: 6
  defp severity(:critical), do: 7
  defp severity(:alert), do: 8
  defp severity(:emergency), do: 9
  defp severity(_), do: 3

  defp format(:logfmt), do: 1
  defp format(_), do: 0
end
