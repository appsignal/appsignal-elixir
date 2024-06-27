defmodule Appsignal.Logger do
  @nif Application.compile_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

  @type log_level ::
          :debug | :info | :notice | :warning | :error | :critical | :alert | :emergency

  @type format :: :json | :logfmt | :plaintext

  @spec debug(String.t(), String.t(), %{} | format()) :: :ok
  def debug(group, message, metadata_or_format \\ %{})

  def debug(group, message, format) when is_atom(format) do
    log(:debug, group, message, %{}, format)
  end

  def debug(group, message, metadata) do
    log(:debug, group, message, metadata)
  end

  @spec info(String.t(), String.t(), %{} | format()) :: :ok
  def info(group, message, metadata_or_format \\ %{})

  def info(group, message, format) when is_atom(format) do
    log(:info, group, message, %{}, format)
  end

  def info(group, message, metadata) do
    log(:info, group, message, metadata)
  end

  @spec notice(String.t(), String.t(), %{} | format()) :: :ok
  def notice(group, message, metadata_or_format \\ %{})

  def notice(group, message, format) when is_atom(format) do
    log(:notice, group, message, %{}, format)
  end

  def notice(group, message, metadata) do
    log(:notice, group, message, metadata)
  end

  @spec warning(String.t(), String.t(), %{} | format()) :: :ok
  def warning(group, message, metadata_or_format \\ %{})

  def warning(group, message, format) when is_atom(format) do
    log(:warning, group, message, %{}, format)
  end

  def warning(group, message, metadata) do
    log(:warning, group, message, metadata)
  end

  @spec error(String.t(), String.t(), %{} | format()) :: :ok
  def error(group, message, metadata_or_format \\ %{})

  def error(group, message, format) when is_atom(format) do
    log(:error, group, message, %{}, format)
  end

  def error(group, message, metadata) do
    log(:error, group, message, metadata)
  end

  @spec critical(String.t(), String.t(), %{} | format()) :: :ok
  def critical(group, message, metadata_or_format \\ %{})

  def critical(group, message, format) when is_atom(format) do
    log(:critical, group, message, %{}, format)
  end

  def critical(group, message, metadata) do
    log(:critical, group, message, metadata)
  end

  @spec alert(String.t(), String.t(), %{} | format()) :: :ok
  def alert(group, message, metadata_or_format \\ %{})

  def alert(group, message, format) when is_atom(format) do
    log(:alert, group, message, %{}, format)
  end

  def alert(group, message, metadata) do
    log(:alert, group, message, metadata)
  end

  @spec emergency(String.t(), String.t(), %{} | format()) :: :ok
  def emergency(group, message, metadata_or_format \\ %{})

  def emergency(group, message, format) when is_atom(format) do
    log(:emergency, group, message, %{}, format)
  end

  def emergency(group, message, metadata) do
    log(:emergency, group, message, metadata)
  end

  @spec log(log_level(), String.t(), String.t(), %{}, format()) :: :ok
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

  defp format(:json), do: 2
  defp format(:logfmt), do: 1
  defp format(:plaintext), do: 0
  defp format(_), do: 0
end
