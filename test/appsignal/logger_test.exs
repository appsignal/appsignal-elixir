defmodule Appsignal.LoggerTest do
  use ExUnit.Case
  alias Appsignal.{Logger, Test}

  setup do
    start_supervised(Test.Nif)
    :ok
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

  test "notice/3 sends the notice log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.notice("app", "This is a notice", metadata)

    assert [{"app", 4, "This is a notice", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "warning/3 sends the warning log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.warning("app", "This is a warning", metadata)

    assert [{"app", 5, "This is a warning", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "error/3 sends the error log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.error("app", "This is an error", metadata)

    assert [{"app", 6, "This is an error", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "critical/3 sends the critical log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.critical("app", "This is a critical", metadata)

    assert [{"app", 7, "This is a critical", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "alert/3 sends the alert log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.alert("app", "This is an alert", metadata)

    assert [{"app", 8, "This is an alert", _encoded_metadata}] = Test.Nif.get!(:log)
  end

  test "emergency/3 sends the emergency log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.emergency("app", "This is an emergency", metadata)

    assert [{"app", 9, "This is an emergency", _encoded_metadata}] = Test.Nif.get!(:log)
  end
end
