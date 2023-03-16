defmodule Appsignal.LoggerTest do
  use ExUnit.Case
  alias Appsignal.{Logger, Test}

  setup do
    start_supervised(Test.Nif)
    :ok
  end

  test "log/5 sends the log calls through the extension" do
    metadata = %{some: "metadata"}

    Logger.log(:debug, "app", "This is a debug", metadata)
    Logger.log(:info, "app", "This is an info", metadata)
    Logger.log(:notice, "app", "This is a notice", metadata)
    Logger.log(:warning, "app", "This is a warning", metadata)
    Logger.log(:warn, "app", "This is a warn", metadata)
    Logger.log(:error, "app", "This is an error", metadata)
    Logger.log(:critical, "app", "This is a critical", metadata)
    Logger.log(:alert, "app", "This is an alert", metadata)
    Logger.log(:emergency, "app", "This is an emergency", metadata)
    Logger.log(:rhubarb, "app", "This is a... rhubarb?", metadata)

    assert [
             {"app", 3, 0, "This is a... rhubarb?", _},
             {"app", 9, 0, "This is an emergency", _},
             {"app", 8, 0, "This is an alert", _},
             {"app", 7, 0, "This is a critical", _},
             {"app", 6, 0, "This is an error", _},
             {"app", 5, 0, "This is a warn", _},
             {"app", 5, 0, "This is a warning", _},
             {"app", 4, 0, "This is a notice", _},
             {"app", 3, 0, "This is an info", _},
             {"app", 2, 0, "This is a debug", _}
           ] = Test.Nif.get!(:log)
  end

  test "debug/3 sends the debug log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.debug("app", "This is a debug", metadata)

    assert [{"app", 2, 0, "This is a debug", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "info/3 sends the info call through the extension" do
    metadata = %{some: "metadata"}

    Logger.info("app", "This is an info", metadata)

    assert [{"app", 3, 0, "This is an info", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "notice/3 sends the notice log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.notice("app", "This is a notice", metadata)

    assert [{"app", 4, 0, "This is a notice", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "warning/3 sends the warning log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.warning("app", "This is a warning", metadata)

    assert [{"app", 5, 0, "This is a warning", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "error/3 sends the error log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.error("app", "This is an error", metadata)

    assert [{"app", 6, 0, "This is an error", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "critical/3 sends the critical log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.critical("app", "This is a critical", metadata)

    assert [{"app", 7, 0, "This is a critical", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "alert/3 sends the alert log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.alert("app", "This is an alert", metadata)

    assert [{"app", 8, 0, "This is an alert", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "emergency/3 sends the emergency log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.emergency("app", "This is an emergency", metadata)

    assert [{"app", 9, 0, "This is an emergency", _encoded_metadata}] = Test.Nif.get!(:log)
  end
end
