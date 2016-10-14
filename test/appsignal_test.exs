defmodule AppsignalTest do
  use ExUnit.Case

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
  end

  test "Agent environment variables" do
    System.put_env("APPSIGNAL_ENVIRONMENT", "test")
    Application.put_env(:appsignal, :config, env: :test)

    Appsignal.Config.initialize()

    env = Appsignal.Config.get_system_env()
    assert "test" = env["APPSIGNAL_ENVIRONMENT"]

    config = Application.get_env :appsignal, :config
    assert :test = config[:env]
  end
end
