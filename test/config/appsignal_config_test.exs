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
       APPSIGNAL_FILTER_PARAMETERS
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
    assert default_configuration == init_config
  end

  describe "using the application environment" do
    setup do
      Application.put_env(
        :appsignal, :config,
        push_api_key: "00000000-0000-0000-0000-000000000000"
      )
    end

    test "valid configuration" do
      assert valid_configuration == init_config
    end

    test "active" do
      add_to_application_env(:active, false)
      assert valid_configuration |> Map.put(:active, false) == init_config
      assert "false" == System.get_env("APPSIGNAL_ACTIVE")
    end

    test "name" do
      add_to_application_env(:name, :my_application)
      assert valid_configuration |> Map.put(:name, :my_application) == init_config
      assert "my_application" == System.get_env("APPSIGNAL_APP_NAME")
    end

    test "debug" do
      add_to_application_env(:debug, true)
      assert valid_configuration |> Map.put(:debug, true) == init_config
      assert "true" == System.get_env("APPSIGNAL_DEBUG_LOGGING")
    end

    test "filter_parameters" do
      add_to_application_env(:filter_parameters, ~w(password secret))
      assert valid_configuration |> Map.put(:filter_parameters, ~w(password secret)) == init_config
      assert "password,secret" == System.get_env("APPSIGNAL_FILTER_PARAMETERS")
    end

    test "frontend_error_catching_path" do
      add_to_application_env(:frontend_error_catching_path, "/appsignal_error_catcher")
      assert valid_configuration |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config
    end

    test "http_proxy" do
      add_to_application_env(:http_proxy, "http://10.10.10.10:8888")
      assert valid_configuration |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config
      assert "http://10.10.10.10:8888" == System.get_env("APPSIGNAL_HTTP_PROXY")
    end

    test "ignore_actions" do
      actions = ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      )
      add_to_application_env(:ignore_actions, actions)
      assert valid_configuration |> Map.put(:ignore_actions, actions) == init_config
      assert "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored" == System.get_env("APPSIGNAL_IGNORE_ACTIONS")
    end

    test "ignore_errors" do
      errors = ~w(VerySpecificError AnotherError)
      add_to_application_env(:ignore_errors, errors)
      assert valid_configuration |> Map.put(:ignore_errors, errors) == init_config
      assert "VerySpecificError,AnotherError" == System.get_env("APPSIGNAL_IGNORE_ERRORS")
    end

    test "enable_host_metrics" do
      add_to_application_env(:enable_host_metrics, true)
      assert valid_configuration |> Map.put(:enable_host_metrics, true) == init_config
      assert "true" == System.get_env("APPSIGNAL_ENABLE_HOST_METRICS")
    end

    test "log" do
      add_to_application_env(:log, "stdout")
      assert valid_configuration |> Map.put(:log, "stdout") == init_config
    end

    test "log_path" do
      add_to_application_env(:log_path, "log/appsignal.log")
      assert valid_configuration |> Map.put(:log_path, "log/appsignal.log") == init_config
      assert "log/appsignal.log" == System.get_env("APPSIGNAL_LOG_FILE_PATH")
    end

    test "endpoint" do
      add_to_application_env(:endpoint, "https://push.staging.lol")
      assert valid_configuration |> Map.put(:endpoint, "https://push.staging.lol") == init_config
      assert "https://push.staging.lol" == System.get_env("APPSIGNAL_PUSH_API_ENDPOINT")
    end

    test "running_in_container" do
      add_to_application_env(:running_in_container, true)
      assert valid_configuration |> Map.put(:running_in_container, true) == init_config
      assert "true" == System.get_env("APPSIGNAL_RUNNING_IN_CONTAINER")
    end

    test "send_params" do
      add_to_application_env(:send_params, true)
      assert valid_configuration |> Map.put(:send_params, true) == init_config
    end

    test "skip_session_data" do
      add_to_application_env(:skip_session_data, true)
      assert valid_configuration |> Map.put(:skip_session_data, true) == init_config
    end

    test "working_dir_path" do
      add_to_application_env(:working_dir_path, "/tmp/appsignal")
      assert valid_configuration |> Map.put(:working_dir_path, "/tmp/appsignal") == init_config
      assert "/tmp/appsignal" == System.get_env("APPSIGNAL_WORKING_DIR_PATH")
    end

    test "revision" do
      add_to_application_env(:revision, "03bd9e")
      assert valid_configuration |> Map.put(:revision, "03bd9e") == init_config
      assert "03bd9e" == System.get_env("APP_REVISION")
    end
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

  defp add_to_application_env(key, value) do
    Application.put_env(:appsignal, :config,
      Application.get_env(:appsignal, :config) ++ [{key, value}]
    )
  end

  defp init_config do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end
end
