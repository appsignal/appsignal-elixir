defmodule Appsignal.IntegrationLoggerTest do
  import AppsignalTest.Utils
  use ExUnit.Case

  setup do
    Application.delete_env(:appsignal, :"$log_file_path")
    start_supervised!(FakeIO)
    start_supervised!(FakeFile)
    :ok
  end

  test "all methods log messages when config log level is trace" do
    with_config(%{log_level: "trace"}, fn ->
      Appsignal.IntegrationLogger.trace("trace!")
      Appsignal.IntegrationLogger.debug("debug!")
      Appsignal.IntegrationLogger.info("info!")
      Appsignal.IntegrationLogger.warn("warning!")
      Appsignal.IntegrationLogger.error("error!")
    end)

    until(fn -> assert FakeFile.count() == 5 end)

    expected = [
      %{"level" => "ERROR", "message" => "error!"},
      %{"level" => "WARNING", "message" => "warning!"},
      %{"level" => "INFO", "message" => "info!"},
      %{"level" => "DEBUG", "message" => "debug!"},
      %{"level" => "TRACE", "message" => "trace!"}
    ]

    actual =
      Enum.map(
        FakeFile.all(),
        fn {_, output, _} -> match_file_format(output) end
      )

    assert expected == actual
  end

  test "only error method logs messages when config log level is error" do
    with_config(%{log_level: "error"}, fn ->
      Appsignal.IntegrationLogger.trace("trace!")
      Appsignal.IntegrationLogger.debug("debug!")
      Appsignal.IntegrationLogger.info("info!")
      Appsignal.IntegrationLogger.warn("warning!")
      Appsignal.IntegrationLogger.error("error!")
    end)

    until(fn -> assert FakeFile.count() == 1 end)

    [{_, output, _}] = FakeFile.all()
    assert %{"level" => "ERROR", "message" => "error!"} = match_file_format(output)
  end

  test "logs info message when config log level is debug" do
    with_config(%{log_level: "debug"}, fn ->
      Appsignal.IntegrationLogger.info("info!")
    end)

    until(fn -> assert FakeFile.count() == 1 end)

    [{_, output, _}] = FakeFile.all()
    assert %{"level" => "INFO", "message" => "info!"} = match_file_format(output)
  end

  test "logs debug message when config log level is debug" do
    with_config(%{log_level: "debug"}, fn ->
      Appsignal.IntegrationLogger.debug("debug!")
    end)

    until(fn -> assert FakeFile.count() == 1 end)

    [{_, output, _}] = FakeFile.all()
    assert %{"level" => "DEBUG", "message" => "debug!"} = match_file_format(output)
  end

  test "does not log trace message when config log level is debug" do
    with_config(%{log_level: "debug"}, fn ->
      Appsignal.IntegrationLogger.trace("trace!")
    end)

    repeatedly(fn -> assert FakeFile.count() == 0 end)
  end

  test "logs to file by default" do
    with_config(%{}, fn ->
      Appsignal.IntegrationLogger.info("info!")
    end)

    until(fn ->
      assert FakeFile.count() == 1
      assert FakeIO.count() == 0
    end)

    [{file, output, modes}] = FakeFile.all()
    assert file == "/tmp/appsignal.log"
    assert %{"level" => "INFO", "message" => "info!"} = match_file_format(output)
    assert modes == [:append, :utf8]
  end

  test "logs to stdout when config log is stdout" do
    with_config(%{log: "stdout"}, fn ->
      Appsignal.IntegrationLogger.info("info!")
    end)

    until(fn ->
      assert FakeIO.count() == 1
      assert FakeFile.count() == 0
    end)

    [{device, output}] = FakeIO.all()
    assert device == :stdio
    assert %{"level" => "INFO", "message" => "info!"} = match_stdout_format(output)
  end

  test "logs to stderr instead of stdout when stderr is set" do
    with_config(%{log: "stdout"}, fn ->
      Appsignal.IntegrationLogger.warn("warning!", stderr: true)
    end)

    until(fn ->
      assert FakeIO.count() == 1
      assert FakeFile.count() == 0
    end)

    [{device, output}] = FakeIO.all()
    assert device == :stderr
    assert %{"level" => "WARNING", "message" => "warning!"} = match_stderr_format(output)
  end

  test "logs to stderr and to file when stderr is set" do
    with_config(%{}, fn ->
      Appsignal.IntegrationLogger.warn("warning!", stderr: true)
    end)

    until(fn ->
      assert FakeIO.count() == 1
      assert FakeFile.count() == 1
    end)

    [{device, device_output}] = FakeIO.all()
    [{file, file_output, modes}] = FakeFile.all()

    assert device == :stderr
    assert %{"level" => "WARNING", "message" => "warning!"} = match_stderr_format(device_output)

    assert file == "/tmp/appsignal.log"
    assert %{"level" => "WARNING", "message" => "warning!"} = match_file_format(file_output)
    assert modes == [:append, :utf8]
  end

  test "will log to the given path when log_path is set" do
    File.mkdir("/tmp/foo")
    on_exit(fn -> File.rm_rf("/tmp/foo") end)

    with_config(%{log_path: "/tmp/foo"}, fn ->
      Appsignal.IntegrationLogger.warn("warning!")
    end)

    until(fn -> assert FakeFile.count() == 1 end)

    [{file, _, _}] = FakeFile.all()
    assert file == "/tmp/foo/appsignal.log"
  end

  defp match_file_format(output) do
    regex = ~r/^\[[\d\-:T]{19} \(process\) #\d+\]\[(?<level>\w+)\] (?<message>.*)\n$/
    match_format(output, regex)
  end

  defp match_stdout_format(output) do
    regex = ~r/^\n\[[\d\-:T]{19} \(process\) #\d+\]\[appsignal\]\[(?<level>\w+)\] (?<message>.*)$/
    match_format(output, regex)
  end

  defp match_stderr_format(output) do
    regex = ~r/^\n\[appsignal\]\[(?<level>\w+)\] (?<message>.*)$/
    match_format(output, regex)
  end

  defp match_format(output, regex) do
    captures = Regex.named_captures(regex, output)
    assert captures != nil
    captures
  end
end
