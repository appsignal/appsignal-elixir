defmodule Appsignal.ConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Config

  setup do
    clear_env()
    on_exit &clear_env/0
  end

  test "unconfigured" do
    assert {:error, :invalid_config} = Config.initialize()
  end

  test "minimum config from OS env" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
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

  describe "active?" do
    test "when active and valid" do
      Application.put_env(:appsignal, :config, %{active: true, valid: true})
      assert Config.active?
    end

    test "when active but not valid" do
      Application.put_env(:appsignal, :config, %{active: true, valid: false})
      refute Config.active?
    end

    test "when not active and not valid" do
      Application.put_env(:appsignal, :config, %{active: false, valid: false})
      refute Config.active?
    end
  end

  describe "using the application environment" do
    setup do: Application.put_env(:appsignal, :config, [])

    test "active" do
      add_to_application_env(:active, true)
      assert default_configuration() |> Map.put(:active, true) == init_config()
    end

    test "ca_file_path" do
      add_to_application_env(:ca_file_path, "/foo/bar/zab.ca")
      assert default_configuration() |> Map.put(:ca_file_path, "/foo/bar/zab.ca") == init_config()
    end

    test "debug" do
      add_to_application_env(:debug, true)
      assert default_configuration() |> Map.put(:debug, true) == init_config()
    end

    test "enable_host_metrics" do
      add_to_application_env(:enable_host_metrics, false)
      assert default_configuration() |> Map.put(:enable_host_metrics, false) == init_config()
    end

    test "endpoint" do
      add_to_application_env(:endpoint, "https://push.staging.lol")
      assert default_configuration() |> Map.put(:endpoint, "https://push.staging.lol") == init_config()
    end

    test "env" do
      add_to_application_env(:env, :prod)
      assert default_configuration() |> Map.put(:env, :prod) == init_config()
    end

    test "filter_parameters" do
      add_to_application_env(:filter_parameters, ~w(password secret))
      assert default_configuration() |> Map.put(:filter_parameters, ~w(password secret)) == init_config()
    end

    test "frontend_error_catching_path" do
      add_to_application_env(:frontend_error_catching_path, "/appsignal_error_catcher")
      assert default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config()
    end

    test "hostname" do
      add_to_application_env(:hostname, "Bobs-MPB.example.com")
      assert default_configuration() |> Map.put(:hostname, "Bobs-MPB.example.com") == init_config()
    end

    test "http_proxy" do
      add_to_application_env(:http_proxy, "http://10.10.10.10:8888")
      assert default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config()
    end

    test "ignore_actions" do
      actions = ~w(
        ExampleApplication.PageController#ignored
        ExampleApplication.PageController#also_ignored
      )
      add_to_application_env(:ignore_actions, actions)
      assert default_configuration() |> Map.put(:ignore_actions, actions) == init_config()
    end

    test "ignore_errors" do
      errors = ~w(VerySpecificError AnotherError)
      add_to_application_env(:ignore_errors, errors)
      assert default_configuration() |> Map.put(:ignore_errors, errors) == init_config()
    end

    test "log" do
      add_to_application_env(:log, "stdout")
      assert default_configuration() |> Map.put(:log, "stdout") == init_config()
    end

    test "log_path" do
      add_to_application_env(:log_path, "log/appsignal.log")
      assert default_configuration() |> Map.put(:log_path, "log/appsignal.log") == init_config()
    end

    test "name" do
      add_to_application_env(:name, "my application")
      assert default_configuration() |> Map.put(:name, "my application") == init_config()
    end

    test "push_api_key" do
      add_to_application_env(:push_api_key, "00000000-0000-0000-0000-000000000000")
      assert valid_configuration() |> Map.put(:active, false) == init_config()
    end

    test "running_in_container" do
      add_to_application_env(:running_in_container, true)
      assert default_configuration() |> Map.put(:running_in_container, true) == init_config()
    end

    test "send_params" do
      add_to_application_env(:send_params, true)
      assert default_configuration() |> Map.put(:send_params, true) == init_config()
    end

    test "skip_session_data" do
      add_to_application_env(:skip_session_data, true)
      assert default_configuration() |> Map.put(:skip_session_data, true) == init_config()
    end

    test "working_dir_path" do
      add_to_application_env(:working_dir_path, "/tmp/appsignal")
      assert default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal") == init_config()
    end
  end

  describe "using the system environment" do
    test "active" do
      System.put_env("APPSIGNAL_ACTIVE", "true")
      assert default_configuration() |> Map.put(:active, true) == init_config()
    end

    test "ca_file_path" do
      System.put_env("APPSIGNAL_CA_FILE_PATH", "/foo/bar/baz.ca")
      assert default_configuration() |> Map.put(:ca_file_path, "/foo/bar/baz.ca") == init_config()
    end

    test "debug" do
      System.put_env("APPSIGNAL_DEBUG", "true")
      assert default_configuration() |> Map.put(:debug, true) == init_config()
    end

    test "enable_host_metrics" do
      System.put_env("APPSIGNAL_ENABLE_HOST_METRICS", "false")
      assert default_configuration() |> Map.put(:enable_host_metrics, false) == init_config()
    end

    test "endpoint" do
      System.put_env("APPSIGNAL_PUSH_API_ENDPOINT", "https://push.staging.lol")
      assert default_configuration() |> Map.put(:endpoint, "https://push.staging.lol") == init_config()
    end

    test "env" do
      System.put_env("APPSIGNAL_APP_ENV", "prod")
      assert default_configuration() |> Map.put(:env, :prod) == init_config()
    end

    test "filter_parameters" do
      System.put_env("APPSIGNAL_FILTER_PARAMETERS", "password,secret")
      assert default_configuration() |> Map.put(:filter_parameters, ~w(password secret)) == init_config()
    end

    test "frontend_error_catching_path" do
      System.put_env("APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH", "/appsignal_error_catcher")
      assert default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config()
    end

    test "hostname" do
      System.put_env("APPSIGNAL_HOSTNAME", "Bobs-MBP.example.com")
      assert default_configuration() |> Map.put(:hostname, "Bobs-MBP.example.com") == init_config()
    end

    test "http_proxy" do
      System.put_env("APPSIGNAL_HTTP_PROXY", "http://10.10.10.10:8888")
      assert default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config()
    end

    test "ignore_actions" do
      System.put_env("APPSIGNAL_IGNORE_ACTIONS", "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored")
      actions = ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      )
      assert default_configuration() |> Map.put(:ignore_actions, actions) == init_config()
    end

    test "ignore_errors" do
      System.put_env("APPSIGNAL_IGNORE_ERRORS", "VerySpecificError,AnotherError")
      errors = ~w(VerySpecificError AnotherError)
      assert default_configuration() |> Map.put(:ignore_errors, errors) == init_config()
    end

    test "log" do
      System.put_env("APPSIGNAL_LOG", "stdout")
      assert default_configuration() |> Map.put(:log, "stdout") == init_config()
    end

    test "log_path" do
      System.put_env("APPSIGNAL_LOG_PATH", "log/appsignal.log")
      assert default_configuration() |> Map.put(:log_path, "log/appsignal.log") == init_config()
    end

    test "name" do
      System.put_env("APPSIGNAL_APP_NAME", "my_application")
      assert default_configuration() |> Map.put(:name, "my_application") == init_config()
    end

    test "push_api_key" do
      System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
      assert valid_configuration() == init_config()
      assert init_config()[:active] == true
    end

    test "running_in_container" do
      System.put_env("APPSIGNAL_RUNNING_IN_CONTAINER", "true")
      assert default_configuration() |> Map.put(:running_in_container, true) == init_config()
    end

    test "send_params" do
      System.put_env("APPSIGNAL_SEND_PARAMS", "true")
      assert default_configuration() |> Map.put(:send_params, true) == init_config()
    end

    test "skip_session_data" do
      System.put_env("APPSIGNAL_SKIP_SESSION_DATA", "true")
      assert default_configuration() |> Map.put(:skip_session_data, true) == init_config()
    end

    test "working_dir_path" do
      System.put_env("APPSIGNAL_WORKING_DIR_PATH", "/tmp/appsignal")
      assert default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal") == init_config()
    end
  end

  test "system environment overwrites application environment configuration" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
    assert valid_configuration() |> Map.put(:active, true) == init_config()

    clear_env()

    Application.put_env(:appsignal, :config, active: false)
    System.put_env("APPSIGNAL_PUSH_API_KEY", "00000000-0000-0000-0000-000000000000")
    assert valid_configuration() |> Map.put(:active, false) == init_config()
  end

  describe "when on Heroku" do
    setup do
      System.put_env("DYNO", "web.1")
    end

    test ":running_in_container and :log" do
      config = default_configuration()
      |> Map.put(:running_in_container, true)
      |> Map.put(:log, "stdout")
      assert config == init_config()
    end

    test "application environment overwrites :running_in_container config on Heroku" do
      Application.put_env :appsignal, :config, running_in_container: false
      config = default_configuration()
      |> Map.put(:running_in_container, false)
      |> Map.put(:log, "stdout")
      assert config == init_config()
    end

    test "application environment overwrites :log config on Heroku" do
      Application.put_env :appsignal, :config, log: "file"
      config = default_configuration()
      |> Map.put(:running_in_container, true)
      |> Map.put(:log, "file")
      assert config == init_config()
    end
  end

  describe "reset_environment_config!" do
    test "deletes existing configuration in environment" do
      System.put_env("_APPSIGNAL_APP_NAME", "foo")
      Appsignal.Config.reset_environment_config!
      assert System.get_env("_APPSIGNAL_APP_NAME") == nil
    end
  end

  describe "write_to_environment" do
    setup do
      Application.put_env(:appsignal, :config, [])
    end

    defp write_to_environment do
      init_config()
      Appsignal.Config.write_to_environment
    end

    test "empty config options don't get written to the env" do
      write_to_environment()
      assert System.get_env("_APPSIGNAL_APP_NAME") == nil
      assert System.get_env("_APPSIGNAL_CA_FILE_PATH") == nil
      assert System.get_env("_APPSIGNAL_FILTER_PARAMETERS") == nil
      assert System.get_env("_APPSIGNAL_HTTP_PROXY") == nil
      assert System.get_env("_APPSIGNAL_IGNORE_ERRORS") == ""
      assert System.get_env("_APPSIGNAL_IGNORE_ACTIONS") == ""
      assert System.get_env("_APPSIGNAL_LOG_FILE_PATH") == nil
      assert System.get_env("_APPSIGNAL_WORKING_DIR_PATH") == nil
      assert System.get_env("_APPSIGNAL_RUNNING_IN_CONTAINER") == nil
    end

    test "deletes existing configuration in environment" do
      # Name is present in the configuration
      System.put_env("_APPSIGNAL_APP_NAME", "foo")
      # The new config doesn't have a name
      add_to_application_env(:name, "")
      write_to_environment()
      # So it doesn't get written to the new agent environment configuration
      assert System.get_env("_APPSIGNAL_APP_NAME") == nil
    end

    test "writes valid AppSignal config options to the env" do
      add_to_application_env(:active, true)
      add_to_application_env(:ca_file_path, "/foo/bar/zab.ca")
      add_to_application_env(:debug, true)
      add_to_application_env(:enable_host_metrics, false)
      add_to_application_env(:endpoint, "https://push.staging.lol")
      add_to_application_env(:env, :prod)
      add_to_application_env(:filter_parameters, ~w(password secret))
      add_to_application_env(:push_api_key, "00000000-0000-0000-0000-000000000000")
      add_to_application_env(:hostname, "My hostname")
      add_to_application_env(:http_proxy, "http://10.10.10.10:8888")
      add_to_application_env :ignore_actions, ~w(
        ExampleApplication.PageController#ignored
        ExampleApplication.PageController#also_ignored
      )
      add_to_application_env(:ignore_errors, ~w(VerySpecificError AnotherError))
      add_to_application_env(:log, "stdout")
      add_to_application_env(:log_path, "log/appsignal.log")
      add_to_application_env(:name, "My awesome app")
      add_to_application_env(:running_in_container, false)
      add_to_application_env(:working_dir_path, "/tmp/appsignal")
      write_to_environment()

      assert System.get_env("_APPSIGNAL_ACTIVE") == "true"
      assert System.get_env("_APPSIGNAL_AGENT_PATH") == List.to_string(:code.priv_dir(:appsignal))
      assert System.get_env("_APPSIGNAL_AGENT_VERSION") == Appsignal.Agent.version
      assert System.get_env("_APPSIGNAL_APP_NAME") == "My awesome app"
      assert System.get_env("_APPSIGNAL_CA_FILE_PATH") == "/foo/bar/zab.ca"
      assert System.get_env("_APPSIGNAL_DEBUG_LOGGING") == "true"
      assert System.get_env("_APPSIGNAL_ENABLE_HOST_METRICS") == "false"
      assert System.get_env("_APPSIGNAL_ENVIRONMENT") == "prod"
      assert System.get_env("_APPSIGNAL_FILTER_PARAMETERS") == "password,secret"
      assert System.get_env("_APPSIGNAL_HOSTNAME") == "My hostname"
      assert System.get_env("_APPSIGNAL_HTTP_PROXY") == "http://10.10.10.10:8888"
      assert System.get_env("_APPSIGNAL_IGNORE_ACTIONS") == "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored"
      assert System.get_env("_APPSIGNAL_IGNORE_ERRORS") == "VerySpecificError,AnotherError"
      assert System.get_env("_APPSIGNAL_LANGUAGE_INTEGRATION_VERSION") == "elixir-" <> Mix.Project.config[:version]
      assert System.get_env("_APPSIGNAL_LOG") == "stdout"
      assert System.get_env("_APPSIGNAL_LOG_FILE_PATH") == "log/appsignal.log"
      assert System.get_env("_APPSIGNAL_PUSH_API_ENDPOINT") == "https://push.staging.lol"
      assert System.get_env("_APPSIGNAL_PUSH_API_KEY") == "00000000-0000-0000-0000-000000000000"
      assert System.get_env("_APPSIGNAL_RUNNING_IN_CONTAINER") == "false"
      assert System.get_env("_APPSIGNAL_SEND_PARAMS") == "true"
      assert System.get_env("_APPSIGNAL_WORKING_DIR_PATH") == "/tmp/appsignal"
    end

    test "name as atom" do
      add_to_application_env(:name, :my_application)
      write_to_environment()
      assert System.get_env("_APPSIGNAL_APP_NAME") == "my_application"
    end

    test "name as string" do
      add_to_application_env(:name, "My awesome application")
      write_to_environment()
      assert System.get_env("_APPSIGNAL_APP_NAME") == "My awesome application"
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

  defp add_to_application_env(key, value) do
    Application.put_env(:appsignal, :config,
      Application.get_env(:appsignal, :config) ++ [{key, value}]
    )
  end

  defp init_config() do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end
end
