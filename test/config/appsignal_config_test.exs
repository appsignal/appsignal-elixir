defmodule AppsignalConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case

  alias Appsignal.Config

  test "unconfigured" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "")
    Application.delete_env(:appsignal, :config)
    assert {:error, :invalid_config} = Config.initialize()
  end

  test "minimum config from OS env" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "-test-")
    assert :ok = Config.initialize()
  end

  test "minimum config from application env" do
    Application.put_env(:appsignal, :config,
      push_api_key: "-test")
    assert :ok = Config.initialize()
  end

  test "app revision" do
    System.put_env("APP_REVISION", "0c497d")
    assert "0c497d" = init_config()[:revision]
  end

  test "app revision from application env" do
    System.delete_env("APP_REVISION")
    Application.put_env(:appsignal, :config,
      push_api_key: "-test",
      revision: "b5f2b9")
    assert "b5f2b9" = init_config()[:revision]
  end

  test "app config from application env gets put in system env" do
    System.delete_env("APPSIGNAL_ACTIVE")
    System.delete_env("APPSIGNAL_ENVIRONMENT")
    System.delete_env("APPSIGNAL_PUSH_API_KEY")
    System.delete_env("APPSIGNAL_APP_NAME")
    System.delete_env("APPSIGNAL_ENABLE_HOST_METRICS")
    System.delete_env("APP_REVISION")

    Application.put_env(:appsignal, :config,
      active: true,
      env: :prod,
      debug: true,
      log_path: "log/appsignal.log",
      push_api_endpoint: "https://push.appsignal.com",
      push_api_key: "00000000-0000-0000-0000-000000000000",
      name: :ExampleApplication,
      http_proxy: "http://10.10.10.10:8888",
      ignore_actions: ["ExampleApplication.PageController#ignored"],
      ignore_errors: ["VerySpecificError"],
      working_dir_path: "/tmp/appsignal",
      enable_host_metrics: true,
      revision: "03bd9e")
    init_config()
    assert "true" = System.get_env("APPSIGNAL_ACTIVE")
    assert "prod" = System.get_env("APPSIGNAL_ENVIRONMENT")
    assert "true" = System.get_env("APPSIGNAL_DEBUG_LOGGING")
    assert "log/appsignal.log" = System.get_env("APPSIGNAL_LOG_FILE_PATH")
    assert "https://push.appsignal.com" = System.get_env("APPSIGNAL_PUSH_API_ENDPOINT")
    assert "00000000-0000-0000-0000-000000000000" = System.get_env("APPSIGNAL_PUSH_API_KEY")
    assert "ExampleApplication" = System.get_env("APPSIGNAL_APP_NAME")
    assert "http://10.10.10.10:8888" = System.get_env("APPSIGNAL_HTTP_PROXY")
    assert "ExampleApplication.PageController#ignored" = System.get_env("APPSIGNAL_IGNORE_ACTIONS")
    assert "VerySpecificError" = System.get_env("APPSIGNAL_IGNORE_ERRORS")
    assert "/tmp/appsignal" = System.get_env("APPSIGNAL_WORKING_DIR_PATH")
    assert "true" = System.get_env("APPSIGNAL_ENABLE_HOST_METRICS")
    assert "03bd9e" = System.get_env("APP_REVISION")
  end

  defp init_config do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end

end
