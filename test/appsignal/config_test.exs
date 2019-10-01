defmodule Appsignal.ConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case
  import AppsignalTest.Utils
  import ExUnit.CaptureIO
  alias Appsignal.{Config, Nif}

  setup do
    environment = freeze_environment()
    Application.delete_env(:appsignal, :config)
    Application.delete_env(:appsignal, :config_sources)

    ExUnit.Callbacks.on_exit(fn ->
      unfreeze_environment(environment)
    end)
  end

  describe "initialize" do
    test "stores sources in Application" do
      init_config()

      default =
        default_configuration()
        |> Map.delete(:valid)

      assert Application.get_env(:appsignal, :config_sources) == %{
               default: default,
               system: %{},
               file: %{},
               env: %{}
             }
    end

    test "stores file sources in Application" do
      config = %{name: "My app", active: true}

      assert with_config(
               config,
               fn ->
                 init_config()
                 Application.get_env(:appsignal, :config_sources)[:file]
               end
             ) == config
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

  describe "configured_as_active?" do
    test "when active" do
      assert with_config(
               %{active: true, valid: true},
               &Config.configured_as_active?/0
             )
    end

    test "when not active" do
      refute with_config(
               %{active: false, valid: true},
               &Config.configured_as_active?/0
             )
    end
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

    test "when the configuration is not a map" do
      refute with_frozen_environment(fn ->
               Application.put_env(:appsignal, :config, [])
               Config.active?()
             end)
    end
  end

  describe "request_headers" do
    test "is nil by default" do
      assert with_config(%{}, &Config.request_headers/0) == nil
    end

    test "returns the request_headers config" do
      assert with_config(%{request_headers: []}, &Config.request_headers/0) == []
    end
  end

  describe "ca_file_path" do
    setup do
      Config.initialize()
      :ok
    end

    test "uses the priv path by default" do
      assert with_config(%{}, &Config.ca_file_path/0) ==
               Path.join(:code.priv_dir(:appsignal), "cacert.pem")
    end

    test "returns user override when set" do
      assert with_config(%{ca_file_path: "/foo/bar/bat.ca"}, &Config.ca_file_path/0) ==
               "/foo/bar/bat.ca"
    end

    test "returns nil when set to nil" do
      assert with_config(%{ca_file_path: nil}, &Config.ca_file_path/0) == nil
    end
  end

  describe "using the application environment" do
    test "active" do
      assert %{active: true} = with_config(%{active: true}, &init_config/0)
    end

    test "ca_file_path" do
      assert %{ca_file_path: "/foo/bar/baz.ca"} =
               with_config(%{ca_file_path: "/foo/bar/baz.ca"}, &init_config/0)
    end

    test "debug" do
      assert %{debug: true} = with_config(%{debug: true}, &init_config/0)
    end

    test "dns_servers" do
      assert %{dns_servers: ["8.8.8.8", "8.8.4.4"]} =
               with_config(%{dns_servers: ["8.8.8.8", "8.8.4.4"]}, &init_config/0)
    end

    test "enable_host_metrics" do
      assert %{enable_host_metrics: false} =
               with_config(%{enable_host_metrics: false}, &init_config/0)
    end

    test "enable_minutely_probes" do
      assert %{enable_minutely_probes: false} =
               with_config(%{enable_minutely_probes: false}, &init_config/0)
    end

    test "endpoint" do
      assert %{endpoint: "https://push.staging.lol"} =
               with_config(%{endpoint: "https://push.staging.lol"}, &init_config/0)
    end

    test "env" do
      assert %{env: :prod} = with_config(%{env: :prod}, &init_config/0)
    end

    test "filter_parameters" do
      assert %{filter_parameters: ~w(password secret)} =
               with_config(%{filter_parameters: ~w(password secret)}, &init_config/0)
    end

    test "filter_session_data" do
      assert %{filter_session_data: ~w(accept connection)} =
               with_config(%{filter_session_data: ~w(accept connection)}, &init_config/0)
    end

    test "frontend_error_catching_path" do
      assert %{frontend_error_catching_path: "/appsignal_error_catcher"} =
               with_config(
                 %{frontend_error_catching_path: "/appsignal_error_catcher"},
                 &init_config/0
               )
    end

    test "hostname" do
      assert %{hostname: "Bobs-MBP.example.com"} =
               with_config(%{hostname: "Bobs-MBP.example.com"}, &init_config/0)
    end

    test "http_proxy" do
      assert %{http_proxy: "http://10.10.10.10:8888"} =
               with_config(%{http_proxy: "http://10.10.10.10:8888"}, &init_config/0)
    end

    test "ignore_actions" do
      actions = ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
      )

      assert %{ignore_actions: ^actions} = with_config(%{ignore_actions: actions}, &init_config/0)
    end

    test "ignore_errors" do
      errors = ~w(VerySpecificError AnotherError)

      assert %{ignore_errors: ^errors} = with_config(%{ignore_errors: errors}, &init_config/0)
    end

    test "ignore_namespaces" do
      namespaces = ~w(admin private_namespace)

      assert %{ignore_namespaces: ^namespaces} =
               with_config(%{ignore_namespaces: namespaces}, &init_config/0)
    end

    test "log" do
      assert %{log: "stdout"} = with_config(%{log: "stdout"}, &init_config/0)
    end

    test "log_path" do
      log_path = File.cwd!()

      assert %{log_path: ^log_path} = with_config(%{log_path: log_path}, &init_config/0)
    end

    test "name" do
      assert %{name: "AppSignal test suite app"} =
               with_config(%{name: "AppSignal test suite app"}, &init_config/0)
    end

    test "push_api_key" do
      assert %{active: false} =
               with_config(
                 %{push_api_key: "00000000-0000-0000-0000-000000000000"},
                 &init_config/0
               )
    end

    test "running_in_container" do
      assert %{running_in_container: true} =
               with_config(%{running_in_container: true}, &init_config/0)
    end

    test "send_params" do
      assert %{send_params: true} = with_config(%{send_params: true}, &init_config/0)
    end

    test "skip_session_data" do
      assert %{skip_session_data: true} = with_config(%{skip_session_data: true}, &init_config/0)
    end

    test "files_world_accessible" do
      assert %{files_world_accessible: true} =
               with_config(%{files_world_accessible: true}, &init_config/0)
    end

    test "working_dir_path" do
      without_logger(fn ->
        assert %{working_dir_path: "/tmp/appsignal"} =
                 with_config(%{working_dir_path: "/tmp/appsignal"}, &init_config/0)
      end)
    end

    test "working_directory_path" do
      assert %{working_directory_path: "/tmp/appsignal"} =
               with_config(%{working_directory_path: "/tmp/appsignal"}, &init_config/0)
    end

    test "request_headers" do
      assert %{request_headers: ~w(accept accept-charset)} =
               with_config(%{request_headers: ~w(accept accept-charset)}, &init_config/0)
    end

    test "revision" do
      assert %{revision: "03bd9e"} = with_config(%{revision: "03bd9e"}, &init_config/0)
    end
  end

  describe "using the system environment" do
    test "stores system env source in Application" do
      assert with_env(
               %{"APPSIGNAL_ACTIVE" => "true", "APPSIGNAL_DEBUG" => "true"},
               fn ->
                 init_config()
                 Application.get_env(:appsignal, :config_sources)[:env]
               end
             ) == %{active: true, debug: true}
    end

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

    test "dns_servers" do
      assert with_env(
               %{"APPSIGNAL_DNS_SERVERS" => "8.8.8.8,8.8.4.4"},
               &init_config/0
             ) == default_configuration() |> Map.put(:dns_servers, ["8.8.8.8", "8.8.4.4"])
    end

    test "enable_host_metrics" do
      assert with_env(
               %{"APPSIGNAL_ENABLE_HOST_METRICS" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:enable_host_metrics, false)
    end

    test "enable_minutely_probes" do
      assert with_env(
               %{"APPSIGNAL_ENABLE_MINUTELY_PROBES" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:enable_minutely_probes, false)
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

    test "filter_session_data" do
      assert with_env(
               %{"APPSIGNAL_FILTER_SESSION_DATA" => "accept,connection"},
               &init_config/0
             ) == default_configuration() |> Map.put(:filter_session_data, ~w(accept connection))
    end

    test "frontend_error_catching_path" do
      assert with_env(
               %{"APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH" => "/appsignal_error_catcher"},
               &init_config/0
             ) ==
               default_configuration()
               |> Map.put(:frontend_error_catching_path, "/appsignal_error_catcher")
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
               %{
                 "APPSIGNAL_IGNORE_ACTIONS" =>
                   "ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored"
               },
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
             ) ==
               default_configuration()
               |> Map.put(:ignore_errors, ~w(VerySpecificError AnotherError))
    end

    test "ignore_namespaces" do
      assert with_env(
               %{"APPSIGNAL_IGNORE_NAMESPACES" => "admin,private_namespace"},
               &init_config/0
             ) ==
               default_configuration() |> Map.put(:ignore_namespaces, ~w(admin private_namespace))
    end

    test "log" do
      assert with_env(
               %{"APPSIGNAL_LOG" => "stdout"},
               &init_config/0
             ) == default_configuration() |> Map.put(:log, "stdout")
    end

    test "log_path" do
      log_path = File.cwd!()

      assert with_env(
               %{"APPSIGNAL_LOG_PATH" => log_path},
               &init_config/0
             ) == default_configuration() |> Map.put(:log_path, log_path)
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
               %{"APPSIGNAL_SEND_PARAMS" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:send_params, false)
    end

    test "skip_session_data" do
      assert with_env(
               %{"APPSIGNAL_SKIP_SESSION_DATA" => "true"},
               &init_config/0
             ) == default_configuration() |> Map.put(:skip_session_data, true)
    end

    test "files_world_accessible" do
      assert with_env(
               %{"APPSIGNAL_FILES_WORLD_ACCESSIBLE" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:files_world_accessible, false)
    end

    test "working_dir_path" do
      without_logger(fn ->
        assert with_env(
                 %{"APPSIGNAL_WORKING_DIR_PATH" => "/tmp/appsignal"},
                 &init_config/0
               ) == default_configuration() |> Map.put(:working_dir_path, "/tmp/appsignal")
      end)
    end

    test "working_directory_path" do
      assert with_env(
               %{"APPSIGNAL_WORKING_DIRECTORY_PATH" => "/tmp/appsignal"},
               &init_config/0
             ) == default_configuration() |> Map.put(:working_directory_path, "/tmp/appsignal")
    end

    test "request_headers" do
      assert with_env(
               %{"APPSIGNAL_REQUEST_HEADERS" => "accept,accept-charset"},
               &init_config/0
             ) == default_configuration() |> Map.put(:request_headers, ~w(accept accept-charset))
    end

    test "revision" do
      assert with_env(
               %{"APP_REVISION" => "03bd9e"},
               &init_config/0
             ) == default_configuration() |> Map.put(:revision, "03bd9e")
    end
  end

  describe "config based on system" do
    test "system environment overwrites application environment configuration" do
      assert with_env(
               %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
               &init_config/0
             ) == valid_configuration() |> Map.put(:active, true)

      assert with_config(%{active: false}, fn ->
               with_env(
                 %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
                 &init_config/0
               )
             end) == valid_configuration() |> Map.put(:active, false)
    end

    test "stores system source in Application" do
      assert with_env(
               %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
               fn ->
                 init_config()
                 Application.get_env(:appsignal, :config_sources)[:system]
               end
             ) == %{active: true}

      assert with_config(%{active: false}, fn ->
               with_env(
                 %{"APPSIGNAL_PUSH_API_KEY" => "00000000-0000-0000-0000-000000000000"},
                 fn ->
                   init_config()
                   Application.get_env(:appsignal, :config_sources)[:system]
                 end
               )
             end) == %{active: true}
    end
  end

  describe "when on Heroku" do
    setup do
      setup_with_env(%{"DYNO" => "web.1"})
    end

    test "stores system source in Application" do
      init_config()

      assert Application.get_env(:appsignal, :config_sources)[:system] == %{
               log: "stdout",
               running_in_container: true
             }
    end

    test ":running_in_container and :log" do
      config =
        default_configuration()
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

  describe "log_file_path/0" do
    test "defaults to /tmp/appsignal.log" do
      system_tmp_dir = Appsignal.Utils.FileSystem.system_tmp_dir()

      with_config(%{}, fn ->
        assert Config.log_file_path() == Path.join(system_tmp_dir, "appsignal.log")
      end)
    end

    test "overrides user specified filename when set" do
      output =
        capture_io(:stderr, fn ->
          system_tmp_dir = Appsignal.Utils.FileSystem.system_tmp_dir()

          with_config(%{log_path: Path.join(system_tmp_dir, "custom.log")}, fn ->
            assert Config.log_file_path() == Path.join(system_tmp_dir, "appsignal.log")
          end)
        end)

      assert output =~ "Deprecation warning: File names are no longer supported in the 'log_path'"
    end

    test "falls back on /tmp/appsignal.log when user path is not writable" do
      log_path = "/non_existent_path"
      system_tmp_dir = Appsignal.Utils.FileSystem.system_tmp_dir()

      output =
        capture_io(:stderr, fn ->
          with_config(%{log_path: log_path}, fn ->
            assert Config.log_file_path() == Path.join(system_tmp_dir, "appsignal.log")
          end)
        end)

      assert output =~
               "appsignal: Unable to log to '#{log_path}' or the " <>
                 "'#{system_tmp_dir}' fallback. " <>
                 "Please check the write permissions for the log directory."
    end
  end

  describe "reset_environment_config!" do
    test "deletes existing configuration in environment" do
      assert with_env(
               %{"_APPSIGNAL_APP_NAME" => "AppSignal test suite app"},
               fn ->
                 Appsignal.Config.reset_environment_config!()
                 Nif.env_get("_APPSIGNAL_APP_NAME")
               end
             ) == ''
    end
  end

  describe "write_to_environment" do
    defp write_to_environment do
      init_config()
      Appsignal.Config.write_to_environment()
    end

    @tag :skip_env_test_no_nif
    test "empty config options get written to the env" do
      write_to_environment()
      assert Nif.env_get("_APPSIGNAL_APP_NAME") == ''
      assert Nif.env_get("_APPSIGNAL_HTTP_PROXY") == ''
      assert Nif.env_get("_APPSIGNAL_IGNORE_ACTIONS") == ''
      assert Nif.env_get("_APPSIGNAL_IGNORE_ERRORS") == ''
      assert Nif.env_get("_APPSIGNAL_IGNORE_NAMESPACES") == ''
      assert Nif.env_get("_APPSIGNAL_LOG_FILE_PATH") == '/tmp/appsignal.log'
      assert Nif.env_get("_APPSIGNAL_WORKING_DIR_PATH") == ''
      assert Nif.env_get("_APPSIGNAL_WORKING_DIRECTORY_PATH") == ''
      assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == ''
      assert Nif.env_get("_APP_REVISION") == ''
    end

    test "deletes existing configuration in environment" do
      with_env(
        # Name is present in the configuration
        %{"_APPSIGNAL_APP_NAME" => "AppSignal test suite app"},
        fn ->
          # The new config doesn't have a name
          with_config(%{name: ""}, fn ->
            write_to_environment()
            # So it doesn't get written to the new agent environment configuration
            assert Nif.env_get("_APPSIGNAL_APP_NAME") == ''
          end)
        end
      )
    end

    @tag :skip_env_test_no_nif
    test "writes valid AppSignal config options to the env" do
      with_config(
        %{
          active: true,
          ca_file_path: "/foo/bar/zab.ca",
          debug: true,
          dns_servers: ["8.8.8.8", "8.8.4.4"],
          enable_host_metrics: false,
          endpoint: "https://push.staging.lol",
          env: :prod,
          push_api_key: "00000000-0000-0000-0000-000000000000",
          hostname: "My hostname",
          http_proxy: "http://10.10.10.10:8888",
          ignore_actions: ~w(
          ExampleApplication.PageController#ignored
          ExampleApplication.PageController#also_ignored
        ),
          ignore_errors: ~w(VerySpecificError AnotherError),
          ignore_namespaces: ~w(admin private_namespace),
          log: "stdout",
          log_path: "/tmp",
          name: "AppSignal test suite app",
          running_in_container: false,
          working_dir_path: "/tmp/appsignal-deprecated",
          working_directory_path: "/tmp/appsignal",
          files_world_accessible: false,
          revision: "03bd9e"
        },
        fn ->
          without_logger(&write_to_environment/0)

          assert Nif.env_get("_APPSIGNAL_ACTIVE") == 'true'
          assert Nif.env_get("_APPSIGNAL_AGENT_PATH") == :code.priv_dir(:appsignal)
          assert Nif.env_get("_APPSIGNAL_APP_NAME") == 'AppSignal test suite app'
          assert Nif.env_get("_APPSIGNAL_CA_FILE_PATH") == '/foo/bar/zab.ca'
          assert Nif.env_get("_APPSIGNAL_DEBUG_LOGGING") == 'true'
          assert Nif.env_get("_APPSIGNAL_DNS_SERVERS") == '8.8.8.8,8.8.4.4'
          assert Nif.env_get("_APPSIGNAL_ENABLE_HOST_METRICS") == 'false'
          assert Nif.env_get("_APPSIGNAL_ENVIRONMENT") == 'prod'
          assert Nif.env_get("_APPSIGNAL_HOSTNAME") == 'My hostname'
          assert Nif.env_get("_APPSIGNAL_HTTP_PROXY") == 'http://10.10.10.10:8888'

          assert Nif.env_get("_APPSIGNAL_IGNORE_ACTIONS") ==
                   'ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored'

          assert Nif.env_get("_APPSIGNAL_IGNORE_ERRORS") == 'VerySpecificError,AnotherError'
          assert Nif.env_get("_APPSIGNAL_IGNORE_NAMESPACES") == 'admin,private_namespace'

          assert Nif.env_get("_APPSIGNAL_LANGUAGE_INTEGRATION_VERSION") ==
                   'elixir-' ++ String.to_charlist(Mix.Project.config()[:version])

          assert Nif.env_get("_APPSIGNAL_LOG") == 'stdout'
          assert Nif.env_get("_APPSIGNAL_LOG_FILE_PATH") == '/tmp/appsignal.log'
          assert Nif.env_get("_APPSIGNAL_PUSH_API_ENDPOINT") == 'https://push.staging.lol'
          assert Nif.env_get("_APPSIGNAL_PUSH_API_KEY") == '00000000-0000-0000-0000-000000000000'
          assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == 'false'
          assert Nif.env_get("_APPSIGNAL_WORKING_DIR_PATH") == '/tmp/appsignal-deprecated'
          assert Nif.env_get("_APPSIGNAL_WORKING_DIRECTORY_PATH") == '/tmp/appsignal'
          assert Nif.env_get("_APPSIGNAL_FILES_WORLD_ACCESSIBLE") == 'false'
          assert Nif.env_get("_APP_REVISION") == '03bd9e'
        end
      )
    end

    @tag :skip_env_test_no_nif
    test "name as atom" do
      with_config(%{name: :appsignal_test_suite_app}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_APP_NAME") == 'appsignal_test_suite_app'
      end)
    end

    @tag :skip_env_test_no_nif
    test "name as string" do
      with_config(%{name: "AppSignal test suite app"}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_APP_NAME") == 'AppSignal test suite app'
      end)
    end

    test "writes dns_servers to env if empty" do
      with_config(%{dns_servers: []}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_DNS_SERVERS") == ''
      end)
    end

    @tag :skip_env_test_no_nif
    test "handles atom fields as strings" do
      with_config(
        %{
          active: "true",
          debug: "false",
          enable_host_metrics: "true",
          env: "prod",
          running_in_container: "false",
          files_world_accessible: "false"
        },
        fn ->
          write_to_environment()

          assert Nif.env_get("_APPSIGNAL_ACTIVE") == 'true'
          assert Nif.env_get("_APPSIGNAL_DEBUG_LOGGING") == 'false'
          assert Nif.env_get("_APPSIGNAL_ENABLE_HOST_METRICS") == 'true'
          assert Nif.env_get("_APPSIGNAL_ENVIRONMENT") == 'prod'
          assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == 'false'
          assert Nif.env_get("_APPSIGNAL_FILES_WORLD_ACCESSIBLE") == 'false'
        end
      )
    end

    @tag :skip_env_test_no_nif
    test "writes default ca_file_path to env if not user configured" do
      with_config(%{}, fn ->
        write_to_environment()

        assert Nif.env_get("_APPSIGNAL_CA_FILE_PATH") ==
                 to_charlist(default_configuration()[:ca_file_path])
      end)
    end

    @tag :skip_env_test_no_nif
    test "writes empty strint ca_file_path to env if user configured to nil" do
      with_config(%{ca_file_path: nil}, fn ->
        write_to_environment()

        assert Nif.env_get("_APPSIGNAL_CA_FILE_PATH") == ''
      end)
    end
  end

  defp default_configuration do
    %{
      active: false,
      debug: false,
      dns_servers: [],
      enable_host_metrics: true,
      enable_minutely_probes: true,
      endpoint: "https://push.appsignal.com",
      diagnose_endpoint: "https://appsignal.com/diag",
      env: :dev,
      filter_parameters: [],
      filter_session_data: [],
      ignore_actions: [],
      ignore_errors: [],
      ignore_namespaces: [],
      send_params: true,
      skip_session_data: false,
      files_world_accessible: true,
      valid: false,
      log: "file",
      request_headers: ~w(
        accept accept-charset accept-encoding accept-language cache-control
        connection content-length path-info range request-method request-uri
        server-name server-port server-protocol
      ),
      ca_file_path: Path.join(:code.priv_dir(:appsignal), "cacert.pem")
    }
  end

  defp valid_configuration do
    default_configuration()
    |> Map.put(:active, true)
    |> Map.put(:valid, true)
    |> Map.put(:push_api_key, "00000000-0000-0000-0000-000000000000")
  end

  defp init_config do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end

  defp without_logger(fun) do
    Logger.disable(self())
    fun.()
    Logger.enable(self())
  end
end
