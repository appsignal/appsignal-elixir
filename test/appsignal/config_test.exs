defmodule Appsignal.ConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case

  alias Appsignal.Config

  setup do
    clear_env()
    on_exit &clear_env/0
  end

  test "unconfigured" do
    assert {:error, :invalid_config} = Config.initialize()
  end

  test "minimum config from OS env" do
    System.put_env(
      "APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000"
    )
    assert :ok = Config.initialize()
  end

  test "minimum config from application env" do
    Application.put_env(
      :appsignal, :config,
      push_api_key: "00000000-0000-0000-0000-000000000000"
    )
    assert :ok = Config.initialize()
  end

  test "default configuration" do
    assert default_configuration() == init_config()
  end

  describe "using the application environment" do
    setup do
      Application.put_env(
        :appsignal, :config,
        []
      )
    end

    test "active" do
      add_to_application_env(:active, true)
      assert default_configuration() |> Map.put(:active, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_ACTIVE")
    end

    test "ca_file_path" do
      add_to_application_env(:ca_file_path, "/foo/bar/zab.ca")
      assert default_configuration() |> Map.put(:ca_file_path, "/foo/bar/zab.ca") == init_config()
      assert "/foo/bar/zab.ca" == System.get_env("APPSIGNAL_CA_FILE_PATH")
    end

    test "debug" do
      add_to_application_env(:debug, true)
      assert default_configuration() |> Map.put(:debug, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_DEBUG_LOGGING")
    end

    test "enable_host_metrics" do
      add_to_application_env(:enable_host_metrics, false)
      assert default_configuration() |> Map.put(:enable_host_metrics, false) == init_config()
      assert "false" == System.get_env("APPSIGNAL_ENABLE_HOST_METRICS")
    end

    test "endpoint" do
      add_to_application_env(:endpoint, "https://push.staging.lol")
      assert default_configuration() |> Map.put(:endpoint, "https://push.staging.lol") == init_config()
      assert "https://push.staging.lol" == System.get_env("APPSIGNAL_PUSH_API_ENDPOINT")
    end

    test "env" do
      add_to_application_env(:env, :prod)
      assert default_configuration() |> Map.put(:env, :prod) == init_config()
      assert "prod" == System.get_env("APPSIGNAL_ENVIRONMENT")
    end

    test "filter_parameters" do
      add_to_application_env(:filter_parameters, ~w(password secret))
      assert default_configuration() |> Map.put(:filter_parameters, ~w(password secret)) == init_config()
      assert "password,secret" == System.get_env("APPSIGNAL_FILTER_PARAMETERS")
    end

    test "frontend_error_catching_path" do
      add_to_application_env(:frontend_error_catching_path, "/appsignal_error_catcher")
      assert default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config()
    end

    test "hostname" do
      add_to_application_env(:hostname, "Bobs-MPB.example.com")
      assert default_configuration() |> Map.put(:hostname, "Bobs-MPB.example.com") == init_config()
      assert "Bobs-MPB.example.com" == System.get_env("APPSIGNAL_HOSTNAME")
    end

    test "http_proxy" do
      add_to_application_env(:http_proxy, "http://10.10.10.10:8888")
      assert default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config()
      assert "http://10.10.10.10:8888" == System.get_env("APPSIGNAL_HTTP_PROXY")
    end

    test "ignore_actions" do
      actions = ~w(
        ExampleApplication.PageController#ignored
        ExampleApplication.PageController#also_ignored
      )
      add_to_application_env(:ignore_actions, actions)
      assert default_configuration() |> Map.put(:ignore_actions, actions) == init_config()
      assert "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored" == System.get_env("APPSIGNAL_IGNORE_ACTIONS")
    end

    test "ignore_errors" do
      errors = ~w(VerySpecificError AnotherError)
      add_to_application_env(:ignore_errors, errors)
      assert default_configuration() |> Map.put(:ignore_errors, errors) == init_config()
      assert "VerySpecificError,AnotherError" == System.get_env("APPSIGNAL_IGNORE_ERRORS")
    end

    test "log" do
      add_to_application_env(:log, "stdout")
      assert default_configuration() |> Map.put(:log, "stdout") == init_config()
      assert "stdout" == System.get_env("APPSIGNAL_LOG")
    end

    test "log_path" do
      add_to_application_env(:log_path, "log/appsignal.log")
      assert default_configuration() |> Map.put(:log_path, "log/appsignal.log") == init_config()
      assert "log/appsignal.log" == System.get_env("APPSIGNAL_LOG_FILE_PATH")
    end

    test "name" do
      add_to_application_env(:name, :my_application)
      assert default_configuration() |> Map.put(:name, :my_application) == init_config()
      assert "my_application" == System.get_env("APPSIGNAL_APP_NAME")
    end

    test "push_api_key" do
      add_to_application_env(:push_api_key, "00000000-0000-0000-0000-000000000000")
      assert valid_configuration() |> Map.put(:active, false) == init_config()
      assert "00000000-0000-0000-0000-000000000000" == System.get_env("APPSIGNAL_PUSH_API_KEY")
    end

    test "revision" do
      add_to_application_env(:revision, "03bd9e")
      assert default_configuration() |> Map.put(:revision, "03bd9e") == init_config()
      assert "03bd9e" == System.get_env("APP_REVISION")
    end

    test "running_in_container" do
      add_to_application_env(:running_in_container, true)
      assert default_configuration() |> Map.put(:running_in_container, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
    end

    test "send_params" do
      add_to_application_env(:send_params, true)
      assert default_configuration() |> Map.put(:send_params, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_SEND_PARAMS")
    end

    test "skip_session_data" do
      add_to_application_env(:skip_session_data, true)
      assert default_configuration() |> Map.put(:skip_session_data, true) == init_config()
    end

    test "working_dir_path" do
      add_to_application_env(:working_dir_path, "/tmp/appsignal")
      assert default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal") == init_config()
      assert "/tmp/appsignal" == System.get_env("APPSIGNAL_WORKING_DIR_PATH")
    end
  end

  describe "using the system environment" do
    test "active" do
      System.put_env("APPSIGNAL_ACTIVE", "true")
      assert default_configuration() |> Map.put(:active, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_ACTIVE")
    end

    test "ca_file_path" do
      System.put_env("APPSIGNAL_CA_FILE_PATH", "/foo/bar/baz.ca")
      assert default_configuration() |> Map.put(:ca_file_path, "/foo/bar/baz.ca") == init_config()
      assert "/foo/bar/baz.ca" == System.get_env("APPSIGNAL_CA_FILE_PATH")
    end

    test "debug" do
      System.put_env("APPSIGNAL_DEBUG", "true")
      assert default_configuration() |> Map.put(:debug, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_DEBUG_LOGGING")
    end

    test "enable_host_metrics" do
      System.put_env("APPSIGNAL_ENABLE_HOST_METRICS", "false")
      assert default_configuration() |> Map.put(:enable_host_metrics, false) == init_config()
      assert "false" == System.get_env("APPSIGNAL_ENABLE_HOST_METRICS")
    end

    test "endpoint" do
      System.put_env("APPSIGNAL_PUSH_API_ENDPOINT", "https://push.staging.lol")
      assert default_configuration() |> Map.put(:endpoint, "https://push.staging.lol") == init_config()
      assert "https://push.staging.lol" == System.get_env("APPSIGNAL_PUSH_API_ENDPOINT")
    end

    test "env" do
      System.put_env("APPSIGNAL_APP_ENV", "prod")
      assert default_configuration() |> Map.put(:env, :prod) == init_config()
      assert "prod" == System.get_env("APPSIGNAL_APP_ENV")
      assert "prod" == System.get_env("APPSIGNAL_ENVIRONMENT")
    end

    test "filter_parameters" do
      System.put_env("APPSIGNAL_FILTER_PARAMETERS", "password,secret")
      assert default_configuration() |> Map.put(:filter_parameters, ~w(password secret)) == init_config()
      assert "password,secret" == System.get_env("APPSIGNAL_FILTER_PARAMETERS")
    end

    test "frontend_error_catching_path" do
      System.put_env("APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH", "/appsignal_error_catcher")
      assert default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config()
      assert "/appsignal_error_catcher" == System.get_env("APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH")
    end

    test "hostname" do
      System.put_env("APPSIGNAL_HOSTNAME", "Bobs-MBP.example.com")
      assert default_configuration() |> Map.put(:hostname, "Bobs-MBP.example.com") == init_config()
      assert "Bobs-MBP.example.com" == System.get_env("APPSIGNAL_HOSTNAME")
    end

    test "http_proxy" do
      System.put_env("APPSIGNAL_HTTP_PROXY", "http://10.10.10.10:8888")
      assert default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config()
      assert "http://10.10.10.10:8888" == System.get_env("APPSIGNAL_HTTP_PROXY")
    end

    test "ignore_actions" do
      System.put_env("APPSIGNAL_IGNORE_ACTIONS", "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored")
      actions = ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      )
      assert default_configuration() |> Map.put(:ignore_actions, actions) == init_config()
      assert "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored" == System.get_env("APPSIGNAL_IGNORE_ACTIONS")
    end

    test "ignore_errors" do
      System.put_env("APPSIGNAL_IGNORE_ERRORS", "VerySpecificError,AnotherError")
      errors = ~w(VerySpecificError AnotherError)
      assert default_configuration() |> Map.put(:ignore_errors, errors) == init_config()
      assert "VerySpecificError,AnotherError" == System.get_env("APPSIGNAL_IGNORE_ERRORS")
    end

    test "log" do
      System.put_env("APPSIGNAL_LOG", "stdout")
      assert default_configuration() |> Map.put(:log, "stdout") == init_config()
      assert "stdout" == System.get_env("APPSIGNAL_LOG")
    end

    test "log_path" do
      System.put_env("APPSIGNAL_LOG_PATH", "log/appsignal.log")
      assert default_configuration() |> Map.put(:log_path, "log/appsignal.log") == init_config()
      assert "log/appsignal.log" == System.get_env("APPSIGNAL_LOG_FILE_PATH")
    end

    test "name" do
      System.put_env("APPSIGNAL_APP_NAME", "my_application")
      assert default_configuration() |> Map.put(:name, :my_application) == init_config()
      assert "my_application" == System.get_env("APPSIGNAL_APP_NAME")
    end

    test "push_api_key" do
      System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
      assert valid_configuration() == init_config()
      assert "true" == System.get_env("APPSIGNAL_ACTIVE")
      assert "00000000-0000-0000-0000-000000000000" == System.get_env("APPSIGNAL_PUSH_API_KEY")
    end

    test "without push_api_key" do
      assert default_configuration() == init_config()
      assert "false" == System.get_env("APPSIGNAL_ACTIVE")
      assert "" == System.get_env("APPSIGNAL_PUSH_API_KEY")
    end

    test "revision" do
      System.put_env("APP_REVISION", "03bd9e")
      assert default_configuration() |> Map.put(:revision, "03bd9e") == init_config()
      assert "03bd9e" == System.get_env("APP_REVISION")
    end

    test "running_in_container" do
      System.put_env("APPSIGNAL_RUNNING_IN_CONTAINER", "true")
      assert default_configuration() |> Map.put(:running_in_container, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
    end

    test "send_params" do
      System.put_env("APPSIGNAL_SEND_PARAMS", "true")
      assert default_configuration() |> Map.put(:send_params, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_SEND_PARAMS")
    end

    test "skip_session_data" do
      System.put_env("APPSIGNAL_SKIP_SESSION_DATA", "true")
      assert default_configuration() |> Map.put(:skip_session_data, true) == init_config()
      assert "true" == System.get_env("APPSIGNAL_SKIP_SESSION_DATA")
    end

    test "working_dir_path" do
      System.put_env("APPSIGNAL_WORKING_DIR_PATH", "/tmp/appsignal")
      assert default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal") == init_config()
      assert "/tmp/appsignal" == System.get_env("APPSIGNAL_WORKING_DIR_PATH")
    end
  end

  test "system environment overwrites application environment configuration" do
    Application.put_env(
      :appsignal, :config,
      push_api_key: "11111111-1111-1111-1111-111111111111"
    )
    System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")

    assert valid_configuration() == init_config()
    assert "00000000-0000-0000-0000-000000000000" == System.get_env("APPSIGNAL_PUSH_API_KEY")
  end

  describe "on Heroku" do
    setup do
      System.put_env("DYNO", "web.1")
    end

    test ":running_in_container and :log" do
      assert default_heroku_configuration() == init_config()
      assert "true" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
      assert "stdout" == System.get_env("APPSIGNAL_LOG")
    end

    test "application environment overwrites :running_in_container config on Heroku" do
      Application.put_env(
        :appsignal, :config,
        running_in_container: false
      )
      assert default_heroku_configuration() |> Map.put(:running_in_container, false) == init_config()
      assert "false" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
    end

    test "application environment overwrites :log config on Heroku" do
      Application.put_env(
        :appsignal, :config,
        log: "file"
      )
      assert default_heroku_configuration() |> Map.put(:log, "file") == init_config()
      assert "file" == System.get_env("APPSIGNAL_LOG")
    end

    test "push_api_key" do
      System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
      assert valid_heroku_configuration() == init_config()
      assert "true" == System.get_env("APPSIGNAL_ACTIVE")
      assert "true" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
      assert "stdout" == System.get_env("APPSIGNAL_LOG")
      assert "00000000-0000-0000-0000-000000000000" == System.get_env("APPSIGNAL_PUSH_API_KEY")
    end
  end

  defp default_configuration() do
    %{
      active: false,
      debug: false,
      enable_host_metrics: true,
      endpoint: "https://push.appsignal.com",
      env: :dev,
      filter_parameters: nil,
      ignore_actions: [],
      ignore_errors: [],
      running_in_container: false,
      send_params: true,
      skip_session_data: false,
      valid: false,
      log: "file",
      hostname: "Alices-MBP.example.com"
    }
  end

  defp valid_configuration() do
    default_configuration()
    |> Map.put(:active, true)
    |> Map.put(:valid, true)
    |> Map.put(:push_api_key, "00000000-0000-0000-0000-000000000000")
  end

  defp default_heroku_configuration() do
    default_configuration()
    |> Map.put(:running_in_container, true)
    |> Map.put(:log, "stdout")
  end

  defp valid_heroku_configuration() do
    valid_configuration()
    |> Map.put(:running_in_container, true)
    |> Map.put(:log, "stdout")
  end

  defp add_to_application_env(key, value) do
    Application.put_env(:appsignal, :config,
      Application.get_env(:appsignal, :config) ++ [{key, value}]
    )
  end

  defp init_config() do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end

  defp clear_env() do
    Application.delete_env(:appsignal, :config)

    ~w(
      APPSIGNAL_ACTIVE
      APPSIGNAL_APP_NAME
      APPSIGNAL_APP_ENV
      APPSIGNAL_DEBUG
      APPSIGNAL_DEBUG_LOGGING
      APPSIGNAL_CA_FILE_PATH
      APPSIGNAL_ENABLE_HOST_METRICS
      APPSIGNAL_ENVIRONMENT
      APPSIGNAL_FILTER_PARAMETERS
      APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH
      APPSIGNAL_HOSTNAME
      APPSIGNAL_HTTP_PROXY
      APPSIGNAL_IGNORE_ACTIONS
      APPSIGNAL_IGNORE_ERRORS
      APPSIGNAL_LOG
      APPSIGNAL_LOG_PATH
      APPSIGNAL_PUSH_API_ENDPOINT
      APPSIGNAL_PUSH_API_KEY
      APPSIGNAL_RUNNING_IN_CONTAINER
      APPSIGNAL_SKIP_SESSION_DATA
      APPSIGNAL_WORKING_DIR_PATH
      APP_REVISION
      DYNO
    ) |> Enum.each(fn(key) ->
      System.delete_env(key)
    end)
  end
end
