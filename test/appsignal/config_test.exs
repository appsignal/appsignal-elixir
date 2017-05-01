defmodule Appsignal.ConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Config

  setup do
    environment = freeze_environment()
    Application.delete_env(:appsignal, :config)

    ExUnit.Callbacks.on_exit fn() ->
      unfreeze_environment(environment)
    end
  end

  test "unconfigured" do
    assert {:error, :invalid_config} = Config.initialize()
  end

  test "minimum config from OS env" do
    assert with_env(
      %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
      &Config.initialize/0
    ) == :ok
  end

  test "minimum config from application env" do
    assert with_config(
      %{push_api_key: "00000000-0000-0000-0000-000000000000"},
      &Config.initialize/0
    ) == :ok
  end

  test "default configuration" do
    assert default_configuration() == init_config()
  end

  describe "active?" do
    test "when active and valid" do
      assert with_config(
        %{active: true, valid: true},
        &Config.active?/0
      )
    end

    test "when active but not valid" do
      refute with_config(
        %{active: true, valid: false},
        &Config.active?/0
      )
    end

    test "when not active and not valid" do
      refute with_config(
        %{active: false, valid: true},
        &Config.active?/0
      )
    end
  end

  describe "using the application environment" do
    test "active" do
      assert with_config(%{active: true}, &init_config/0)
        == default_configuration() |> Map.put(:active, true)
    end

    test "ca_file_path" do
      assert with_config(%{ca_file_path: "/foo/bar/baz.ca"}, &init_config/0)
        == default_configuration() |> Map.put(:ca_file_path, "/foo/bar/baz.ca")
    end

    test "debug" do
      assert with_config(%{debug: true}, &init_config/0)
        == default_configuration() |> Map.put(:debug, true)
    end

    test "enable_host_metrics" do
      assert with_config(%{enable_host_metrics: false}, &init_config/0)
        == default_configuration() |> Map.put(:enable_host_metrics, false)
    end

    test "endpoint" do
      assert with_config(%{endpoint: "https://push.staging.lol"}, &init_config/0)
        == default_configuration() |> Map.put(:endpoint, "https://push.staging.lol")
    end

    test "env" do
      assert with_config(%{env: :prod}, &init_config/0)
        == default_configuration() |> Map.put(:env, :prod)
    end

    test "filter_parameters" do
      assert with_config(%{filter_parameters: ~w(password secret)}, &init_config/0)
        == default_configuration() |> Map.put(:filter_parameters, ~w(password secret))
    end

    test "frontend_error_catching_path" do
      assert with_config(%{frontend_error_catching_path: "/appsignal_error_catcher"}, &init_config/0)
        == default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher")
    end

    test "hostname" do
      assert with_config(%{hostname: "Bobs-MBP.example.com"}, &init_config/0)
        == default_configuration() |> Map.put(:hostname, "Bobs-MBP.example.com")
    end

    test "http_proxy" do
      assert with_config(%{http_proxy: "http://10.10.10.10:8888"}, &init_config/0)
        == default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888")
    end

    test "ignore_actions" do
      actions = ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      )

      assert with_config(%{ignore_actions: actions}, &init_config/0)
        == default_configuration() |> Map.put(:ignore_actions, actions)
    end

    test "ignore_errors" do
      errors = ~w(VerySpecificError AnotherError)

      assert with_config(%{ignore_errors: errors}, &init_config/0)
        == default_configuration() |> Map.put(:ignore_errors, errors)
    end

    test "log" do
      assert with_config(%{log: "stdout"}, &init_config/0)
        == default_configuration() |> Map.put(:log, "stdout")
    end

    test "log_path" do
      assert with_config(%{log_path: "log/appsignal.log"}, &init_config/0)
        == default_configuration() |> Map.put(:log_path, "log/appsignal.log")
    end

    test "name" do
      assert with_config(%{name: "AppSignal test suite app"}, &init_config/0)
        == default_configuration() |> Map.put(:name, "AppSignal test suite app")
    end

    test "push_api_key" do
      assert with_config(%{push_api_key: "00000000-0000-0000-0000-000000000000"}, &init_config/0)
        == valid_configuration() |> Map.put(:active, false)
    end

    test "running_in_container" do
      assert with_config(%{running_in_container: true}, &init_config/0)
        == default_configuration() |> Map.put(:running_in_container, true)
    end

    test "send_params" do
      assert with_config(%{send_params: true}, &init_config/0)
        == default_configuration() |> Map.put(:send_params, true)
    end

    test "skip_session_data" do
      assert with_config(%{skip_session_data: true}, &init_config/0)
        == default_configuration() |> Map.put(:skip_session_data, true)
    end

    test "working_dir_path" do
      assert with_config(%{working_dir_path: "/tmp/appsignal"}, &init_config/0)
        == default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal")
    end
  end

  describe "using the system environment" do
    test "active" do
      assert with_env(
        %{"APPSIGNAL_ACTIVE" => "true"},
        &init_config/0
      ) == default_configuration() |> Map.put(:active, true)
    end

    test "ca_file_path" do
      assert with_env(
        %{"APPSIGNAL_CA_FILE_PATH" => "/foo/bar/baz.ca"},
        &init_config/0
      ) == default_configuration() |> Map.put(:ca_file_path, "/foo/bar/baz.ca")
    end

    test "debug" do
      assert with_env(
        %{"APPSIGNAL_DEBUG" => "true"},
        &init_config/0
      ) == default_configuration() |> Map.put(:debug, true)
    end

    test "enable_host_metrics" do
      assert with_env(
        %{"APPSIGNAL_ENABLE_HOST_METRICS" => "false"},
        &init_config/0
      ) == default_configuration() |> Map.put(:enable_host_metrics, false)
    end

    test "endpoint" do
      assert with_env(
        %{"APPSIGNAL_PUSH_API_ENDPOINT" => "https://push.staging.lol"},
        &init_config/0
      ) == default_configuration() |> Map.put(:endpoint, "https://push.staging.lol")
    end

    test "env" do
      assert with_env(
        %{"APPSIGNAL_APP_ENV" => "prod"},
        &init_config/0
      ) == default_configuration() |> Map.put(:env, :prod)
    end

    test "filter_parameters" do
      assert with_env(
        %{"APPSIGNAL_FILTER_PARAMETERS" => "password,secret"},
        &init_config/0
      ) == default_configuration() |> Map.put(:filter_parameters, ~w(password secret))
    end

    test "frontend_error_catching_path" do
      assert with_env(
        %{"APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH" => "/appsignal_error_catcher"},
        &init_config/0
      ) == default_configuration() |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher")
    end

    test "hostname" do
      assert with_env(
        %{"APPSIGNAL_HOSTNAME" => "Bobs-MBP.example.com"},
        &init_config/0
      ) == default_configuration() |> Map.put(:hostname, "Bobs-MBP.example.com")
    end

    test "http_proxy" do
      assert with_env(
        %{"APPSIGNAL_HTTP_PROXY" => "http://10.10.10.10:8888"},
        &init_config/0
      ) == default_configuration() |> Map.put(:http_proxy, "http://10.10.10.10:8888")
    end

    test "ignore_actions" do
      assert with_env(
        %{"APPSIGNAL_IGNORE_ACTIONS" => "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored"},
        &init_config/0
      ) == default_configuration() |> Map.put(:ignore_actions, ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      ))
    end

    test "ignore_errors" do
      assert with_env(
        %{"APPSIGNAL_IGNORE_ERRORS" => "VerySpecificError,AnotherError"},
        &init_config/0
      ) == default_configuration() |> Map.put(:ignore_errors, ~w(VerySpecificError AnotherError))
    end

    test "log" do
      assert with_env(
        %{"APPSIGNAL_LOG" => "stdout"},
        &init_config/0
      ) == default_configuration() |> Map.put(:log, "stdout")
    end

    test "log_path" do
      assert with_env(
        %{"APPSIGNAL_LOG_PATH" => "log/appsignal.log"},
        &init_config/0
      ) == default_configuration() |> Map.put(:log_path, "log/appsignal.log")
    end

    test "name" do
      assert with_env(
        %{"APPSIGNAL_APP_NAME" => "AppSignal test suite app"},
        &init_config/0
      ) == default_configuration() |> Map.put(:name, "AppSignal test suite app")
    end

    test "push_api_key" do
      assert with_env(
        %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
        &init_config/0
      ) == valid_configuration()
    end

    test "running_in_container" do
      assert with_env(
        %{"APPSIGNAL_RUNNING_IN_CONTAINER" => "true"},
        &init_config/0
      ) == default_configuration() |> Map.put(:running_in_container, true)
    end

    test "send_params" do
      assert with_env(
        %{"APPSIGNAL_SEND_PARAMS" => "true"},
        &init_config/0
      ) == default_configuration() |> Map.put(:send_params, true)
    end

    test "skip_session_data" do
      assert with_env(
        %{"APPSIGNAL_SKIP_SESSION_DATA" => "true"},
        &init_config/0
      ) == default_configuration() |> Map.put(:skip_session_data, true)
    end

    test "working_dir_path" do
      assert with_env(
        %{"APPSIGNAL_WORKING_DIR_PATH" => "/tmp/appsignal"},
        &init_config/0
      ) == default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal")
    end
  end

  test "system environment overwrites application environment configuration" do
    assert with_env(
      %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
      &init_config/0
    ) == valid_configuration() |> Map.put(:active, true)

    assert with_config(%{active: false}, fn() ->
      with_env(
        %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
        &init_config/0
      )
    end) == valid_configuration() |> Map.put(:active, false)
  end

  describe "when on Heroku" do
    setup do
      setup_with_env(%{"DYNO" => "web.1"})
    end

    test ":running_in_container and :log" do
      config = default_configuration()
      |> Map.put(:running_in_container, true)
      |> Map.put(:log, "stdout")
      assert config == init_config()
    end

    test "application environment overwrites :running_in_container config on Heroku" do
      assert with_config(%{running_in_container: false}, &init_config/0) ==
        default_configuration()
        |> Map.put(:running_in_container, false)
        |> Map.put(:log, "stdout")
    end

    test "application environment overwrites :log config on Heroku" do
      assert with_config(%{log: "file"}, &init_config/0) ==
        default_configuration()
        |> Map.put(:running_in_container, true)
        |> Map.put(:log, "file")
    end
  end

  describe "reset_environment_config!" do
    test "deletes existing configuration in environment" do
      assert with_env(
        %{"_APPSIGNAL_APP_NAME" => "AppSignal test suite app"},
        fn() ->
          Appsignal.Config.reset_environment_config!
          System.get_env("_APPSIGNAL_APP_NAME")
        end
      ) == nil
    end
  end

  describe "write_to_environment" do
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
      with_env(
        # Name is present in the configuration
        %{"_APPSIGNAL_APP_NAME" => "AppSignal test suite app"},
        fn() ->
          # The new config doesn't have a name
          with_config(%{name: ""}, fn() ->
            write_to_environment()
            # So it doesn't get written to the new agent environment configuration
            assert System.get_env("_APPSIGNAL_APP_NAME")  == nil
          end)
      end)
    end

    test "writes valid AppSignal config options to the env" do
      with_config(%{
        active: true,
        ca_file_path: "/foo/bar/zab.ca",
        debug: true,
        enable_host_metrics: false,
        endpoint: "https://push.staging.lol",
        env: :prod,
        filter_parameters: ~w(password secret),
        push_api_key: "00000000-0000-0000-0000-000000000000",
        hostname: "My hostname",
        http_proxy: "http://10.10.10.10:8888",
        ignore_actions: ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
        ),
        ignore_errors: ~w(VerySpecificError AnotherError),
        log: "stdout",
        log_path: "log/appsignal.log",
        name: "AppSignal test suite app",
        running_in_container: false,
        working_dir_path: "/tmp/appsignal"
      }, fn() ->
        write_to_environment()

        assert System.get_env("_APPSIGNAL_ACTIVE") == "true"
        assert System.get_env("_APPSIGNAL_AGENT_PATH") == List.to_string(:code.priv_dir(:appsignal))
        assert System.get_env("_APPSIGNAL_AGENT_VERSION") == Appsignal.Agent.version
        assert System.get_env("_APPSIGNAL_APP_NAME") == "AppSignal test suite app"
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
      end)
    end

    test "ame as atom" do
      with_config(%{name: :appsignal_test_suite_app}, fn() ->
        write_to_environment()
        assert System.get_env("_APPSIGNAL_APP_NAME") == "appsignal_test_suite_app"
      end)
    end

    test "name as string" do
      with_config(%{name: "AppSignal test suite app"}, fn() ->
        write_to_environment()
        assert System.get_env("_APPSIGNAL_APP_NAME") == "AppSignal test suite app"
      end)
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

  defp init_config() do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end
end
