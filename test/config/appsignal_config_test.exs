defmodule AppsignalConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case

  alias Appsignal.Config

  setup do
    Application.delete_env(:appsignal, :config)

    ~w(
       APPSIGNAL_ACTIVE
       APPSIGNAL_APP_NAME
       APPSIGNAL_ENABLE_HOST_METRICS
       APPSIGNAL_ENVIRONMENT
       APPSIGNAL_HTTP_PROXY
       APPSIGNAL_PUSH_API_ENDPOINT
       APPSIGNAL_PUSH_API_KEY
       APPSIGNAL_RUNNING_IN_CONTAINER
       APPSIGNAL_WORKING_DIR_PATH
       APP_REVISION
     ) |> Enum.each(fn(key) ->
         System.delete_env(key)
       end)
  end

  test "unconfigured" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "")
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

  test "default configuration" do
    assert default_configuration == init_config
  end

  test "valid configuration" do
    Application.put_env(
      :appsignal, :config,
      push_api_key: "00000000-0000-0000-0000-000000000000"
    )
    assert valid_configuration == init_config
  end

  test "app revision" do
    System.put_env("APP_REVISION", "0c497d")
    assert "0c497d" = init_config()[:revision]
  end

  test "app revision from application env" do
    Application.put_env(:appsignal, :config,
      push_api_key: "-test",
      revision: "b5f2b9")
    assert "b5f2b9" = init_config()[:revision]
  end

  test "app config from application env gets put in system env" do

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

  defp default_configuration do
    %{
      active: false,
      debug: false,
      enable_host_metrics: false,
      endpoint: "https://push.appsignal.com",
      env: :dev,
      filter_parameters: nil,
      ignore_actions: [],
      ignore_errors: [],
      running_in_container: false,
      send_params: true,
      skip_session_data: false,
      valid: false
    }
  end

  defp valid_configuration do
    default_configuration
    |> Map.put(:active, true)
    |> Map.put(:push_api_key, "00000000-0000-0000-0000-000000000000")
    |> Map.put(:valid, true)
  end

  defp init_config do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end
end
