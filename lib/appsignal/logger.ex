defmodule Appsignal.Logger do
  require Appsignal.Utils

  @io Appsignal.Utils.compile_env(:appsignal, :io, IO)
  @file_module Appsignal.Utils.compile_env(:appsignal, :file, File)

  @log_levels [:trace, :debug, :info, :warn, :error]

  def trace(message) do
    log(:trace, message, [])
  end

  def debug(message) do
    log(:debug, message, [])
  end

  def info(message) do
    log(:info, message, [])
  end

  def warn(message, options \\ []) do
    log(:warn, message, options)
  end

  def error(message, options \\ []) do
    log(:error, message, options)
  end

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

  defp device do
    case Application.fetch_env!(:appsignal, :config)[:log] do
      "stdout" -> :stdio
      _ -> :file
    end
  end

  defp log_level?(level, threshold) do
    Enum.find_index(@log_levels, &(&1 == level)) >=
      Enum.find_index(@log_levels, &(&1 == threshold))
  end

  defp do_log(device, level, message) do
    time = NaiveDateTime.from_erl!(:calendar.local_time())
    pid = System.pid()

    puts(device, format(device, time, pid, level, message))
  end

  defp puts(:file, content) do
    @file_module.write(Appsignal.Config.log_file_path(), content <> "\n", [:append, :utf8])
  end

  defp puts(device, content) do
    @io.puts(device, content)
  end

  defp format(device, time, pid, level, message) do
    time = format_time(time)
    level = format_level(level)

    case device do
      :stdio -> "\n[#{time} (process) ##{pid}][appsignal][#{level}] #{message}"
      :stderr -> "\n[appsignal][#{level}] #{message}"
      :file -> "[#{time} (process) ##{pid}][#{level}] #{message}"
    end
  end

  defp format_level(level) do
    case level do
      :trace -> "TRACE"
      :debug -> "DEBUG"
      :info -> "INFO"
      :warn -> "WARNING"
      :error -> "ERROR"
    end
  end

  defp format_time(time) do
    time
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_iso8601()
  end
end
