defmodule Appsignal.IntegrationLogger do
  @io Application.compile_env(:appsignal, :io, IO)
  @file_module Application.compile_env(:appsignal, :file, File)

  @log_levels [:trace, :debug, :info, :warn, :error]

  @type log_level :: :trace | :debug | :info | :warn | :error
  @type device :: :stdio | :stderr | :file

  @spec trace(String.t()) :: :ok
  def trace(message) do
    log(:trace, message, [])
  end

  @spec debug(String.t()) :: :ok
  def debug(message) do
    log(:debug, message, [])
  end

  @spec info(String.t()) :: :ok
  def info(message) do
    log(:info, message, [])
  end

  @spec warn(String.t()) :: :ok
  def warn(message, options \\ []) do
    log(:warn, message, options)
  end

  @spec error(String.t()) :: :ok
  def error(message, options \\ []) do
    log(:error, message, options)
  end

  @spec log(log_level(), String.t(), keyword()) :: :ok
  defp log(level, message, options) do
    threshold = Appsignal.Config.log_level()

    if log_level?(level, threshold) do
      case {device(), Keyword.get(options, :stderr, false)} do
        {device, false} ->
          do_log(device, level, message)

        {:stdio, true} ->
          do_log(:stderr, level, message)

        {:file, true} ->
          do_log(:file, level, message)
          do_log(:stderr, level, message)
      end
    end
  end

  @spec device() :: device()
  defp device do
    case Application.fetch_env!(:appsignal, :config)[:log] do
      "stdout" -> :stdio
      _ -> :file
    end
  end

  @spec log_level?(log_level(), log_level()) :: bool()
  defp log_level?(level, threshold) do
    Enum.find_index(@log_levels, &(&1 == level)) >=
      Enum.find_index(@log_levels, &(&1 == threshold))
  end

  @spec do_log(device(), log_level(), String.t()) :: :ok
  defp do_log(device, level, message) do
    time = NaiveDateTime.from_erl!(:calendar.local_time())
    pid = System.pid()

    puts(device, format(device, time, pid, level, message))
  end

  @spec puts(device(), String.t()) :: :ok
  defp puts(device, content)

  defp puts(:file, content) do
    @file_module.write(Appsignal.Config.log_file_path(), content <> "\n", [:append, :utf8])
    :ok
  end

  defp puts(device, content) do
    @io.puts(device, content)
    :ok
  end

  @spec format(device(), NaiveDateTime.t(), binary(), log_level(), String.t()) :: String.t()
  defp format(device, time, pid, level, message) do
    time = format_time(time)
    level = format_level(level)

    case device do
      :stdio -> "\n[#{time} (process) ##{pid}][appsignal][#{level}] #{message}"
      :stderr -> "\n[appsignal][#{level}] #{message}"
      :file -> "[#{time} (process) ##{pid}][#{level}] #{message}"
    end
  end

  @spec format_level(log_level()) :: String.t()
  defp format_level(level) do
    case level do
      :trace -> "TRACE"
      :debug -> "DEBUG"
      :info -> "INFO"
      :warn -> "WARNING"
      :error -> "ERROR"
    end
  end

  @spec format_time(NaiveDateTime.t()) :: String.t()
  defp format_time(time) do
    time
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_iso8601()
  end
end
