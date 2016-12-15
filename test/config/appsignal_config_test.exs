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

  describe "with a valid configuration" do
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
    end

    test "name" do
      add_to_application_env(:name, :my_application)
      assert valid_configuration |> Map.put(:name, :my_application) == init_config
    end

    test "debug" do
      add_to_application_env(:debug, true)
      assert valid_configuration |> Map.put(:debug, true) == init_config
    end

    test "filter_parameters" do
      add_to_application_env(:filter_parameters, ~w(password))
      assert valid_configuration |> Map.put(:filter_parameters, ~w(password)) == init_config
    end

    test "frontend_error_catching_path" do
      add_to_application_env(:frontend_error_catching_path, "/appsignal_error_catcher")
      assert valid_configuration |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher") == init_config
    end

    test "http_proxy" do
      add_to_application_env(:http_proxy, "http://10.10.10.10:8888")
      assert valid_configuration |> Map.put(:http_proxy, "http://10.10.10.10:8888") == init_config
    end

    test "ignore_actions" do
      add_to_application_env(:ignore_actions, ~w(ExampleApplication.PageController#ignored))
      assert valid_configuration |> Map.put(:ignore_actions, ~w(ExampleApplication.PageController#ignored)) == init_config
    end

    test "ignore_errors" do
      add_to_application_env(:ignore_errors, ~w(VerySpecificError))
      assert valid_configuration |> Map.put(:ignore_errors, ~w(VerySpecificError)) == init_config
    end

    test "enable_host_metrics" do
      add_to_application_env(:enable_host_metrics, true)
      assert valid_configuration |> Map.put(:enable_host_metrics, true) == init_config
    end

    test "log" do
      add_to_application_env(:log, "stdout")
      assert valid_configuration |> Map.put(:log, "stdout") == init_config
    end

    test "log_path" do
      add_to_application_env(:log_path, "log/appsignal.log")
      assert valid_configuration |> Map.put(:log_path, "log/appsignal.log") == init_config
    end

    test "endpoint" do
      add_to_application_env(:endpoint, "https://push.staging.lol")
      assert valid_configuration |> Map.put(:endpoint, "https://push.staging.lol") == init_config
    end

    test "running_in_container" do
      add_to_application_env(:running_in_container, true)
      assert valid_configuration |> Map.put(:running_in_container, true) == init_config
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
    end

    test "revision" do
      add_to_application_env(:revision, "03bd9e")
      assert valid_configuration |> Map.put(:revision, "03bd9e") == init_config
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
