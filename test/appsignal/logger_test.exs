defmodule Appsignal.LoggerTest do
  use ExUnit.Case
  alias Appsignal.{Logger, Test}

  setup do
    start_supervised(Test.Nif)
    :ok
  end

  test "trace/3 sends the trace log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.trace("app", "This is a trace", metadata)

    assert [{"app", 1, "This is a trace", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "debug/3 sends the debug log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.debug("app", "This is a debug", metadata)

    assert [{"app", 2, "This is a debug", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "info/3 sends the info call through the extension" do
    metadata = %{some: "metadata"}

    Logger.info("app", "This is an info", metadata)

    assert [{"app", 3, "This is an info", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "warn/3 sends the warn log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.warn("app", "This is a warn", metadata)

    assert [{"app", 5, "This is a warn", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "error/3 sends the error log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.error("app", "This is an error", metadata)

    assert [{"app", 6, "This is an error", _encoded_metadata}] = Test.Nif.get!(:log)
  end
end
