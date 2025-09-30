defmodule Appsignal.LoggerTest do
  use ExUnit.Case
  alias Appsignal.{Logger, Test}

  setup do
    start_supervised(Test.Nif)
    :ok
  end

  test "log/5 sends the right severity through the extension" do
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
             {"app", 2, 3, "This is a debug", _},
             {"app", 3, 3, "This is an info", _},
             {"app", 4, 3, "This is a notice", _},
             {"app", 5, 3, "This is a warning", _},
             {"app", 5, 3, "This is a warn", _},
             {"app", 6, 3, "This is an error", _},
             {"app", 7, 3, "This is a critical", _},
             {"app", 8, 3, "This is an alert", _},
             {"app", 9, 3, "This is an emergency", _},
             {"app", 3, 3, "This is a... rhubarb?", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "log/5 sends the right format through the extension" do
    metadata = %{some: "metadata"}

    Logger.log(:debug, "app", "Hi this is plaintext", metadata)
    Logger.log(:debug, "app", "Hi this is also plaintext", %{}, :plaintext)
    Logger.log(:debug, "app", "msg=\"Hi\" this=logfmt", %{}, :logfmt)
    Logger.log(:debug, "app", "{\"msg\":\"Hi\",\"this\":\"json\"", %{}, :json)
    Logger.log(:debug, "app", "{\"msg\":\"Hi\",\"this\":\"json\"", %{}, :autodetect)

    assert [
             {"app", 2, 3, "Hi this is plaintext", _},
             {"app", 2, 0, "Hi this is also plaintext", _},
             {"app", 2, 1, "msg=\"Hi\" this=logfmt", _},
             {"app", 2, 2, "{\"msg\":\"Hi\",\"this\":\"json\"", _},
             {"app", 2, 3, "{\"msg\":\"Hi\",\"this\":\"json\"", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "debug/3 sends the debug log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.debug("app", "This is a debug", metadata)
    Logger.debug("app", "This is a debug", :plaintext)
    Logger.debug("app", "this=debug", :logfmt)
    Logger.debug("app", "{\"this\":\"debug\"}", :json)
    Logger.debug("app", "{\"this\":\"debug\"}", :autodetect)

    assert [
             {"app", 2, 3, "This is a debug", _},
             {"app", 2, 0, "This is a debug", _},
             {"app", 2, 1, "this=debug", _},
             {"app", 2, 2, "{\"this\":\"debug\"}", _},
             {"app", 2, 3, "{\"this\":\"debug\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "info/3 sends the info log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.info("app", "This is an info", metadata)
    Logger.info("app", "This is an info", :plaintext)
    Logger.info("app", "this=info", :logfmt)
    Logger.info("app", "{\"this\":\"info\"}", :json)
    Logger.info("app", "{\"this\":\"info\"}", :autodetect)

    assert [
             {"app", 3, 3, "This is an info", _},
             {"app", 3, 0, "This is an info", _},
             {"app", 3, 1, "this=info", _},
             {"app", 3, 2, "{\"this\":\"info\"}", _},
             {"app", 3, 3, "{\"this\":\"info\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "notice/3 sends the notice log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.notice("app", "This is a notice", metadata)
    Logger.notice("app", "This is a notice", :plaintext)
    Logger.notice("app", "this=notice", :logfmt)
    Logger.notice("app", "{\"this\":\"notice\"}", :json)
    Logger.notice("app", "{\"this\":\"notice\"}", :autodetect)

    assert [
             {"app", 4, 3, "This is a notice", _},
             {"app", 4, 0, "This is a notice", _},
             {"app", 4, 1, "this=notice", _},
             {"app", 4, 2, "{\"this\":\"notice\"}", _},
             {"app", 4, 3, "{\"this\":\"notice\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "warning/3 sends the warning log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.warning("app", "This is a warning", metadata)
    Logger.warning("app", "This is a warning", :plaintext)
    Logger.warning("app", "this=warning", :logfmt)
    Logger.warning("app", "{\"this\":\"warning\"}", :json)
    Logger.warning("app", "{\"this\":\"warning\"}", :autodetect)

    assert [
             {"app", 5, 3, "This is a warning", _},
             {"app", 5, 0, "This is a warning", _},
             {"app", 5, 1, "this=warning", _},
             {"app", 5, 2, "{\"this\":\"warning\"}", _},
             {"app", 5, 3, "{\"this\":\"warning\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "error/3 sends the error log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.error("app", "This is an error", metadata)
    Logger.error("app", "This is an error", :plaintext)
    Logger.error("app", "this=error", :logfmt)
    Logger.error("app", "{\"this\":\"error\"}", :json)
    Logger.error("app", "{\"this\":\"error\"}", :autodetect)

    assert [
             {"app", 6, 3, "This is an error", _},
             {"app", 6, 0, "This is an error", _},
             {"app", 6, 1, "this=error", _},
             {"app", 6, 2, "{\"this\":\"error\"}", _},
             {"app", 6, 3, "{\"this\":\"error\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "critical/3 sends the critical log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.critical("app", "This is a critical", metadata)
    Logger.critical("app", "This is a critical", :plaintext)
    Logger.critical("app", "this=critical", :logfmt)
    Logger.critical("app", "{\"this\":\"critical\"}", :json)
    Logger.critical("app", "{\"this\":\"critical\"}", :autodetect)

    assert [
             {"app", 7, 3, "This is a critical", _},
             {"app", 7, 0, "This is a critical", _},
             {"app", 7, 1, "this=critical", _},
             {"app", 7, 2, "{\"this\":\"critical\"}", _},
             {"app", 7, 3, "{\"this\":\"critical\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "alert/3 sends the alert log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.alert("app", "This is an alert", metadata)
    Logger.alert("app", "This is an alert", :plaintext)
    Logger.alert("app", "this=alert", :logfmt)
    Logger.alert("app", "{\"this\":\"alert\"}", :json)
    Logger.alert("app", "{\"this\":\"alert\"}", :autodetect)

    assert [
             {"app", 8, 3, "This is an alert", _},
             {"app", 8, 0, "This is an alert", _},
             {"app", 8, 1, "this=alert", _},
             {"app", 8, 2, "{\"this\":\"alert\"}", _},
             {"app", 8, 3, "{\"this\":\"alert\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end

  test "emergency/3 sends the emergency log call through the extension" do
    metadata = %{some: "metadata"}

    Logger.emergency("app", "This is an emergency", metadata)
    Logger.emergency("app", "This is an emergency", :plaintext)
    Logger.emergency("app", "this=emergency", :logfmt)
    Logger.emergency("app", "{\"this\":\"emergency\"}", :json)
    Logger.emergency("app", "{\"this\":\"emergency\"}", :autodetect)

    assert [
             {"app", 9, 3, "This is an emergency", _},
             {"app", 9, 0, "This is an emergency", _},
             {"app", 9, 1, "this=emergency", _},
             {"app", 9, 2, "{\"this\":\"emergency\"}", _},
             {"app", 9, 3, "{\"this\":\"emergency\"}", _}
           ] = Enum.reverse(Test.Nif.get!(:log))
  end
end
