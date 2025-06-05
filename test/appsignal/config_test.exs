defmodule Appsignal.ConfigTest do
  @moduledoc """
  Test the configuration
  """

  use ExUnit.Case
  import AppsignalTest.Utils
  import ExUnit.CaptureIO
  alias Appsignal.{Config, Nif}

  setup do
    environment = freeze_environment()
    Application.delete_env(:appsignal, :config)
    Application.delete_env(:appsignal, :config_sources)
    Application.delete_env(:appsignal, :"$log_file_path")

    ExUnit.Callbacks.on_exit(fn ->
      unfreeze_environment(environment)
    end)
  end

  describe "initialize" do
    test "stores sources in Application" do
      init_config()

      # The send_session_data config must be deleted for this test as it is set up
      # after the config is initialized. This test checks the default configuration hash
      # has the desired shape.
      default = default_configuration() |> Map.drop([:send_session_data, :skip_session_data])

      assert Application.get_env(:appsignal, :config_sources) == %{
               default: default,
               system: %{},
               file: %{},
               env: %{},
               override: %{send_session_data: true, skip_session_data: false}
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

  describe "valid?" do
    test "when a push api key is set up" do
      assert with_config(
               %{push_api_key: "00000000-0000-0000-0000-000000000000"},
               &Config.valid?/0
             )
    end

    test "when no push api key is set up" do
      refute with_config(
               %{push_api_key: nil},
               &Config.valid?/0
             )
    end

    test "when the push api key is an empty string" do
      refute with_config(
               %{push_api_key: ""},
               &Config.valid?/0
             )
    end

    test "when the push api key is filled with whitespaces" do
      refute with_config(
               %{push_api_key: "    "},
               &Config.valid?/0
             )
    end
  end

  describe "configured_as_active?" do
    test "when active" do
      assert with_config(
               %{active: true},
               &Config.configured_as_active?/0
             )
    end

    test "when not active" do
      refute with_config(
               %{active: false},
               &Config.configured_as_active?/0
             )
    end

    test "with an empty config" do
      refute with_config(
               %{},
               &Config.configured_as_active?/0
             )
    end

    test "without an appsignal config" do
      refute without_config(&Config.configured_as_active?/0)
    end
  end

  describe "active?" do
    test "when active and valid" do
      assert with_config(
               %{active: true, push_api_key: "00000000-0000-0000-0000-000000000000"},
               &Config.active?/0
             )
    end

    test "when active and not valid" do
      refute with_config(
               %{push_api_key: nil, active: true},
               &Config.active?/0
             )
    end

    test "when not active and not valid" do
      refute with_config(
               %{push_api_key: nil, active: false},
               &Config.active?/0
             )
    end

    test "when the configuration is not a map" do
      refute with_frozen_environment(fn ->
               Application.put_env(:appsignal, :config, [])
               Config.active?()
             end)
    end

    test "without an appsignal config" do
      refute without_config(&Config.active?/0)
    end
  end

  describe "error_backend_enabled?" do
    test "when true" do
      assert with_config(
               %{enable_error_backend: true},
               &Config.error_backend_enabled?/0
             )
    end

    test "when false" do
      refute with_config(
               %{enable_error_backend: false},
               &Config.error_backend_enabled?/0
             )
    end

    test "when unset" do
      refute with_config(%{}, &Config.error_backend_enabled?/0)
    end

    test "without an appsignal config" do
      refute without_config(&Config.error_backend_enabled?/0)
    end
  end

  describe "instrument_oban?" do
    test "when true" do
      assert with_config(
               %{instrument_oban: true},
               &Config.instrument_oban?/0
             )
    end

    test "when false" do
      refute with_config(
               %{instrument_oban: false},
               &Config.instrument_oban?/0
             )
    end

    test "when unset" do
      assert with_config(%{}, &Config.instrument_oban?/0)
    end

    test "without an appsignal config" do
      assert without_config(&Config.instrument_oban?/0)
    end
  end

  describe "instrument_ecto?" do
    test "when true" do
      assert with_config(
               %{instrument_ecto: true},
               &Config.instrument_ecto?/0
             )
    end

    test "when false" do
      refute with_config(
               %{instrument_ecto: false},
               &Config.instrument_ecto?/0
             )
    end

    test "when unset" do
      assert with_config(%{}, &Config.instrument_ecto?/0)
    end

    test "without an appsignal config" do
      assert without_config(&Config.instrument_ecto?/0)
    end
  end

  describe "instrument_finch?" do
    test "when discard" do
      assert with_config(
               %{instrument_finch: true},
               &Config.instrument_finch?/0
             )
    end

    test "when false" do
      refute with_config(
               %{instrument_finch: false},
               &Config.instrument_finch?/0
             )
    end

    test "when unset" do
      assert with_config(%{}, &Config.instrument_finch?/0)
    end

    test "without an appsignal config" do
      assert without_config(&Config.instrument_finch?/0)
    end
  end

  describe "instrument_tesla?" do
    test "when discard" do
      assert with_config(
               %{instrument_tesla: true},
               &Config.instrument_tesla?/0
             )
    end

    test "when false" do
      refute with_config(
               %{instrument_tesla: false},
               &Config.instrument_tesla?/0
             )
    end

    test "when unset" do
      assert with_config(%{}, &Config.instrument_tesla?/0)
    end

    test "without an appsignal config" do
      assert without_config(&Config.instrument_tesla?/0)
    end
  end

  describe "instrument_absinthe?" do
    test "when true" do
      assert with_config(
               %{instrument_absinthe: true},
               &Config.instrument_absinthe?/0
             )
    end

    test "when false" do
      refute with_config(
               %{instrument_absinthe: false},
               &Config.instrument_absinthe?/0
             )
    end

    test "when unset" do
      assert with_config(%{}, &Config.instrument_absinthe?/0)
    end

    test "without an appsignal config" do
      assert without_config(&Config.instrument_absinthe?/0)
    end
  end

  describe "report_oban_errors" do
    test "when discard" do
      assert with_config(
               %{report_oban_errors: "discard"},
               &Config.report_oban_errors/0
             ) == "discard"
    end

    test "when none or false" do
      assert with_config(
               %{report_oban_errors: "none"},
               &Config.report_oban_errors/0
             ) == "none"

      assert with_config(
               %{report_oban_errors: "false"},
               &Config.report_oban_errors/0
             ) == "none"
    end

    test "when all or true" do
      assert with_config(
               %{report_oban_errors: "all"},
               &Config.report_oban_errors/0
             ) == "all"

      assert with_config(
               %{report_oban_errors: "true"},
               &Config.report_oban_errors/0
             ) == "all"
    end

    test "when something else" do
      without_logger(fn ->
        assert with_config(
                 %{report_oban_errors: "foo"},
                 &Config.report_oban_errors/0
               ) == "all"
      end)
    end

    test "when unset" do
      assert with_config(%{}, &Config.report_oban_errors/0) == "all"
    end

    test "without an appsignal config" do
      assert without_config(&Config.report_oban_errors/0) == "all"
    end
  end

  describe "log_level" do
    test "without an appsignal config" do
      assert without_config(&Config.log_level/0) == :info
    end

    test "when log level is set to a known log level" do
      assert with_config(%{log_level: "warn"}, &Config.log_level/0) == :warn
    end

    test "when log level is set to a known warning log level" do
      assert with_config(%{log_level: "warning"}, &Config.log_level/0) == :warn
    end

    test "when log level is set to an invalid value" do
      assert with_config(%{log_level: "foobar"}, &Config.log_level/0) == :info
    end

    test "when log level is not set" do
      assert with_config(%{}, &Config.log_level/0) == :info
    end

    test "when log level is not set and debug is set" do
      assert with_config(%{debug: true}, &Config.log_level/0) == :debug
    end

    test "when log level is not set and transaction debug mode is set" do
      assert with_config(%{transaction_debug_mode: true}, &Config.log_level/0) == :trace
    end
  end

  describe "debug?" do
    test "when log_level is trace" do
      assert with_config(%{log_level: "trace"}, &Config.debug?/0) == true
    end

    test "when log_level is debug" do
      assert with_config(%{log_level: "debug"}, &Config.debug?/0) == true
    end

    test "when log_level is something other than trace or debug" do
      assert with_config(%{log_level: "warn"}, &Config.debug?/0) == false
    end
  end

  describe "request_headers" do
    test "returns an empty list by default" do
      assert with_config(%{}, &Config.request_headers/0) == []
    end

    test "returns the request_headers config" do
      assert with_config(%{request_headers: []}, &Config.request_headers/0) == []
    end

    test "without an appsignal config" do
      assert without_config(&Config.request_headers/0) ==
               default_configuration()[:request_headers]
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

    test "uses the priv path when no config is set" do
      assert without_config(&Config.ca_file_path/0) ==
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

    test "bind_address" do
      assert %{bind_address: "0.0.0.0"} = with_config(%{bind_address: "0.0.0.0"}, &init_config/0)
    end

    test "ca_file_path" do
      assert %{ca_file_path: "/foo/bar/baz.ca"} =
               with_config(%{ca_file_path: "/foo/bar/baz.ca"}, &init_config/0)
    end

    test "cpu_count" do
      assert %{cpu_count: 1.5} =
               with_config(%{cpu_count: 1.5}, &init_config/0)
    end

    test "debug" do
      assert %{debug: true} = with_config(%{debug: true}, &init_config/0)
    end

    test "dns_servers" do
      assert %{dns_servers: ["8.8.8.8", "8.8.4.4"]} =
               with_config(%{dns_servers: ["8.8.8.8", "8.8.4.4"]}, &init_config/0)
    end

    test "ecto_repos" do
      assert %{ecto_repos: [AppsignalPhoenixExample.Repo]} =
               with_config(%{ecto_repos: [AppsignalPhoenixExample.Repo]}, &init_config/0)
    end

    test "enable_host_metrics" do
      assert %{enable_host_metrics: false} =
               with_config(%{enable_host_metrics: false}, &init_config/0)
    end

    test "enable_minutely_probes" do
      assert %{enable_minutely_probes: false} =
               with_config(%{enable_minutely_probes: false}, &init_config/0)
    end

    test "enable_statsd" do
      assert %{enable_statsd: true} = with_config(%{enable_statsd: true}, &init_config/0)
    end

    test "enable_nginx_metrics" do
      assert %{enable_nginx_metrics: true} =
               with_config(%{enable_nginx_metrics: true}, &init_config/0)
    end

    test "enable_error_backend" do
      assert %{enable_error_backend: false} =
               with_config(%{enable_error_backend: false}, &init_config/0)
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

    test "host_role" do
      assert %{host_role: "host role"} =
               with_config(%{host_role: "host role"}, &init_config/0)
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

    test "ignore_logs" do
      logs = ["^start$", "^Completed 2.* in .*ms$"]

      assert %{ignore_logs: ^logs} = with_config(%{ignore_logs: logs}, &init_config/0)
    end

    test "ignore_namespaces" do
      namespaces = ~w(admin private_namespace)

      assert %{ignore_namespaces: ^namespaces} =
               with_config(%{ignore_namespaces: namespaces}, &init_config/0)
    end

    test "log" do
      assert %{log: "stdout"} = with_config(%{log: "stdout"}, &init_config/0)
    end

    test "log_level" do
      assert %{log_level: "warning"} = with_config(%{log_level: "warning"}, &init_config/0)
    end

    test "log_path" do
      log_path = File.cwd!()

      assert %{log_path: ^log_path} = with_config(%{log_path: log_path}, &init_config/0)
    end

    test "logging_endpoint" do
      assert %{logging_endpoint: "https://push.staging.lol"} =
               with_config(%{logging_endpoint: "https://push.staging.lol"}, &init_config/0)
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

    test "send_session_data" do
      assert %{send_session_data: false, skip_session_data: true} =
               with_config(%{send_session_data: false}, &init_config/0)
    end

    test "skip_session_data" do
      config = %{skip_session_data: true}

      output =
        capture_io(:stderr, fn ->
          assert %{skip_session_data: true, send_session_data: false} =
                   with_config(config, &init_config/0)
        end)

      assert with_config(
               config,
               fn ->
                 init_config()
                 Application.get_env(:appsignal, :config_sources)[:override]
               end
             ) == %{send_session_data: false}

      assert output =~ "Deprecation warning: The `skip_session_data` config option is deprecated."
    end

    test "statsd_port" do
      assert %{statsd_port: "3000"} = with_config(%{statsd_port: "3000"}, &init_config/0)
    end

    test "nginx_port" do
      assert %{nginx_port: "4321"} = with_config(%{nginx_port: "4321"}, &init_config/0)
    end

    test "transaction_debug_mode" do
      assert %{transaction_debug_mode: true} =
               with_config(%{transaction_debug_mode: true}, &init_config/0)
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

    test "send_environment_metadata" do
      assert %{send_environment_metadata: false} =
               with_config(%{send_environment_metadata: false}, &init_config/0)
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

    test "bind_address" do
      assert with_env(
               %{"APPSIGNAL_BIND_ADDRESS" => "0.0.0.0"},
               &init_config/0
             ) == default_configuration() |> Map.put(:bind_address, "0.0.0.0")
    end

    test "ca_file_path" do
      assert with_env(
               %{"APPSIGNAL_CA_FILE_PATH" => "/foo/bar/baz.ca"},
               &init_config/0
             ) == default_configuration() |> Map.put(:ca_file_path, "/foo/bar/baz.ca")
    end

    test "cpu_count" do
      assert with_env(
               %{"APPSIGNAL_CPU_COUNT" => "1.5"},
               &init_config/0
             ) == default_configuration() |> Map.put(:cpu_count, 1.5)
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

    test "ecto_repos" do
      assert with_env(
               %{
                 "APPSIGNAL_ECTO_REPOS" =>
                   "AppsignalPhoenixExample.RepoOne,AppsignalPhoenixExample.RepoTwo"
               },
               &init_config/0
             ) ==
               default_configuration()
               |> Map.put(:ecto_repos, [
                 "AppsignalPhoenixExample.RepoOne",
                 "AppsignalPhoenixExample.RepoTwo"
               ])
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

    test "enable_statsd" do
      assert with_env(
               %{"APPSIGNAL_ENABLE_STATSD" => "true"},
               &init_config/0
             ) == default_configuration() |> Map.put(:enable_statsd, true)
    end

    test "enable_nginx_metrics" do
      assert with_env(
               %{"APPSIGNAL_ENABLE_NGINX_METRICS" => "true"},
               &init_config/0
             ) == default_configuration() |> Map.put(:enable_nginx_metrics, true)
    end

    test "enable_error_backend" do
      assert with_env(
               %{"APPSIGNAL_ENABLE_ERROR_BACKEND" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:enable_error_backend, false)
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
             ) ==
               default_configuration()
               |> Map.merge(%{
                 filter_parameters: ~w(password secret)
               })
    end

    test "filter_session_data" do
      assert with_env(
               %{"APPSIGNAL_FILTER_SESSION_DATA" => "accept,connection"},
               &init_config/0
             ) ==
               default_configuration()
               |> Map.merge(%{
                 filter_session_data: ~w(accept connection)
               })
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

    test "host_role" do
      assert with_env(
               %{"APPSIGNAL_HOST_ROLE" => "host role"},
               &init_config/0
             ) == default_configuration() |> Map.put(:host_role, "host role")
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

    test "ignore_logs" do
      assert with_env(
               %{"APPSIGNAL_IGNORE_LOGS" => "^start$,^Completed 2.* in .*ms$"},
               &init_config/0
             ) ==
               default_configuration()
               |> Map.put(:ignore_logs, ["^start$", "^Completed 2.* in .*ms$"])
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

    test "log_level" do
      assert with_env(
               %{"APPSIGNAL_LOG_LEVEL" => "debug"},
               &init_config/0
             ) == default_configuration() |> Map.put(:log_level, "debug")
    end

    test "log_path" do
      log_path = File.cwd!()

      assert with_env(
               %{"APPSIGNAL_LOG_PATH" => log_path},
               &init_config/0
             ) == default_configuration() |> Map.put(:log_path, log_path)
    end

    test "logging_endpoint" do
      assert with_env(
               %{"APPSIGNAL_LOGGING_ENDPOINT" => "https://push.staging.lol"},
               &init_config/0
             ) ==
               default_configuration() |> Map.put(:logging_endpoint, "https://push.staging.lol")
    end

    test "otp_app" do
      assert with_env(
               %{"APPSIGNAL_OTP_APP" => "appsignal_phoenix_example"},
               &init_config/0
             ) == default_configuration() |> Map.put(:otp_app, :appsignal_phoenix_example)
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

    test "send_session_data" do
      assert with_env(
               %{"APPSIGNAL_SEND_SESSION_DATA" => "false"},
               &init_config/0
             ) ==
               default_configuration()
               |> Map.put(:send_session_data, false)
               |> Map.put(:skip_session_data, true)
    end

    test "skip_session_data" do
      output =
        capture_io(:stderr, fn ->
          assert with_env(
                   %{"APPSIGNAL_SKIP_SESSION_DATA" => "true"},
                   &init_config/0
                 ) ==
                   default_configuration()
                   |> Map.put(:skip_session_data, true)
                   |> Map.put(:send_session_data, false)

          assert with_env(
                   %{"APPSIGNAL_SKIP_SESSION_DATA" => "true"},
                   fn ->
                     init_config()
                     Application.get_env(:appsignal, :config_sources)[:override]
                   end
                 ) == %{send_session_data: false}
        end)

      assert output =~ "Deprecation warning: The `skip_session_data` config option is deprecated."
    end

    test "statsd_port" do
      assert with_env(
               %{"APPSIGNAL_STATSD_PORT" => "3000"},
               &init_config/0
             ) == default_configuration() |> Map.put(:statsd_port, "3000")
    end

    test "transaction_debug_mode" do
      assert with_env(
               %{"APPSIGNAL_TRANSACTION_DEBUG_MODE" => "true"},
               &init_config/0
             ) == default_configuration() |> Map.put(:transaction_debug_mode, true)
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

    test "send_environment_metadata" do
      assert with_env(
               %{"APPSIGNAL_SEND_ENVIRONMENT_METADATA" => "false"},
               &init_config/0
             ) == default_configuration() |> Map.put(:send_environment_metadata, false)
    end

    test "request_headers" do
      assert with_env(
               %{"APPSIGNAL_REQUEST_HEADERS" => "accept,accept-charset"},
               &init_config/0
             ) == default_configuration() |> Map.put(:request_headers, ~w(accept accept-charset))
    end

    test "request_headers overwrites file configuration" do
      assert with_env(
               %{"APPSIGNAL_REQUEST_HEADERS" => "accept,accept-charset"},
               fn ->
                 with_config(
                   %{request_headers: []},
                   &init_config/0
                 )
               end
             ) == default_configuration() |> Map.put(:request_headers, ~w(accept accept-charset))
    end

    test "revision" do
      assert with_env(
               %{"APP_REVISION" => "03bd9e"},
               &init_config/0
             ) == default_configuration() |> Map.put(:revision, "03bd9e")
    end

    test "nginx_port" do
      assert with_env(
               %{"APPSIGNAL_NGINX_PORT" => "4321"},
               &init_config/0
             ) == default_configuration() |> Map.put(:nginx_port, "4321")
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

    test "defaults to /tmp/appsignal.log without a config" do
      system_tmp_dir = Appsignal.Utils.FileSystem.system_tmp_dir()

      without_config(fn ->
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

      # assert warning is emitted only once
      assert capture_io(:stderr, &Config.log_file_path/0) == ""
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

      # assert warning is emitted only once
      assert capture_io(:stderr, &Config.log_file_path/0) == ""
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
             ) == ~c""
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
      assert Nif.env_get("_APPSIGNAL_APP_NAME") == ~c""
      assert Nif.env_get("_APPSIGNAL_BIND_ADDRESS") == ~c""
      assert Nif.env_get("_APPSIGNAL_CPU_COUNT") == ~c""
      assert Nif.env_get("_APPSIGNAL_HTTP_PROXY") == ~c""
      assert Nif.env_get("_APPSIGNAL_IGNORE_ACTIONS") == ~c""
      assert Nif.env_get("_APPSIGNAL_IGNORE_ERRORS") == ~c""
      assert Nif.env_get("_APPSIGNAL_IGNORE_LOGS") == ~c""
      assert Nif.env_get("_APPSIGNAL_IGNORE_NAMESPACES") == ~c""
      assert Nif.env_get("_APPSIGNAL_LOG_FILE_PATH") == ~c"/tmp/appsignal.log"
      assert Nif.env_get("_APPSIGNAL_WORKING_DIR_PATH") == ~c""
      assert Nif.env_get("_APPSIGNAL_WORKING_DIRECTORY_PATH") == ~c""
      assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == ~c""
      assert Nif.env_get("_APPSIGNAL_STATSD_PORT") == ~c""
      assert Nif.env_get("_APPSIGNAL_NGINX_PORT") == ~c""
      assert Nif.env_get("_APP_REVISION") == ~c""
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
            assert Nif.env_get("_APPSIGNAL_APP_NAME") == ~c""
          end)
        end
      )
    end

    @tag :skip_env_test_no_nif
    test "writes valid AppSignal config options to the env" do
      with_config(
        %{
          active: true,
          bind_address: "0.0.0.0",
          ca_file_path: "/foo/bar/zab.ca",
          cpu_count: 1.5,
          debug: true,
          dns_servers: ["8.8.8.8", "8.8.4.4"],
          enable_host_metrics: false,
          endpoint: "https://push.staging.lol",
          env: :prod,
          push_api_key: "00000000-0000-0000-0000-000000000000",
          hostname: "My hostname",
          host_role: "host role",
          http_proxy: "http://10.10.10.10:8888",
          ignore_actions: ~w(
            ExampleApplication.PageController#ignored
            ExampleApplication.PageController#also_ignored
          ),
          ignore_errors: ~w(VerySpecificError AnotherError),
          ignore_logs: ["^start$", "^Completed 2.* in .*ms$"],
          ignore_namespaces: ~w(admin private_namespace),
          log: "stdout",
          log_level: "trace",
          log_path: "/tmp",
          logging_endpoint: "https://push.staging.lol",
          name: "AppSignal test suite app",
          running_in_container: false,
          working_dir_path: "/tmp/appsignal-deprecated",
          working_directory_path: "/tmp/appsignal",
          files_world_accessible: false,
          revision: "03bd9e",
          transaction_debug_mode: true,
          filter_parameters: ["password", "confirm_password"],
          filter_session_data: ["key1", "key2"],
          statsd_port: "3000",
          nginx_port: "1234"
        },
        fn ->
          without_logger(&write_to_environment/0)

          assert Nif.env_get("_APPSIGNAL_ACTIVE") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_AGENT_PATH") == :code.priv_dir(:appsignal)
          assert Nif.env_get("_APPSIGNAL_APP_NAME") == ~c"AppSignal test suite app"
          assert Nif.env_get("_APPSIGNAL_BIND_ADDRESS") == ~c"0.0.0.0"
          assert Nif.env_get("_APPSIGNAL_CA_FILE_PATH") == ~c"/foo/bar/zab.ca"
          assert Nif.env_get("_APPSIGNAL_CPU_COUNT") == ~c"1.5"
          assert Nif.env_get("_APPSIGNAL_DEBUG_LOGGING") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_DNS_SERVERS") == ~c"8.8.8.8,8.8.4.4"
          assert Nif.env_get("_APPSIGNAL_ENABLE_HOST_METRICS") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_APP_ENV") == ~c"prod"
          assert Nif.env_get("_APPSIGNAL_HOSTNAME") == ~c"My hostname"
          assert Nif.env_get("_APPSIGNAL_HOST_ROLE") == ~c"host role"
          assert Nif.env_get("_APPSIGNAL_HTTP_PROXY") == ~c"http://10.10.10.10:8888"

          assert Nif.env_get("_APPSIGNAL_IGNORE_ACTIONS") ==
                   ~c"ExampleApplication.PageController#ignored,ExampleApplication.PageController#also_ignored"

          assert Nif.env_get("_APPSIGNAL_IGNORE_ERRORS") == ~c"VerySpecificError,AnotherError"
          assert Nif.env_get("_APPSIGNAL_IGNORE_LOGS") == ~c"^start$,^Completed 2.* in .*ms$"
          assert Nif.env_get("_APPSIGNAL_IGNORE_NAMESPACES") == ~c"admin,private_namespace"

          assert Nif.env_get("_APPSIGNAL_LANGUAGE_INTEGRATION_VERSION") ==
                   ~c"elixir-" ++ String.to_charlist(Mix.Project.config()[:version])

          assert Nif.env_get("_APPSIGNAL_LOG") == ~c"stdout"
          assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"trace"
          assert Nif.env_get("_APPSIGNAL_LOG_FILE_PATH") == ~c"/tmp/appsignal.log"
          assert Nif.env_get("_APPSIGNAL_LOGGING_ENDPOINT") == ~c"https://push.staging.lol"
          assert Nif.env_get("_APPSIGNAL_PUSH_API_ENDPOINT") == ~c"https://push.staging.lol"

          assert Nif.env_get("_APPSIGNAL_PUSH_API_KEY") ==
                   ~c"00000000-0000-0000-0000-000000000000"

          assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_WORKING_DIR_PATH") == ~c"/tmp/appsignal-deprecated"
          assert Nif.env_get("_APPSIGNAL_WORKING_DIRECTORY_PATH") == ~c"/tmp/appsignal"
          assert Nif.env_get("_APPSIGNAL_FILES_WORLD_ACCESSIBLE") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_TRANSACTION_DEBUG_MODE") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_FILTER_PARAMETERS") == ~c"password,confirm_password"
          assert Nif.env_get("_APPSIGNAL_FILTER_SESSION_DATA") == ~c"key1,key2"
          assert Nif.env_get("_APPSIGNAL_SEND_ENVIRONMENT_METADATA") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_STATSD_PORT") == ~c"3000"
          assert Nif.env_get("_APPSIGNAL_NGINX_PORT") == ~c"1234"
          assert Nif.env_get("_APP_REVISION") == ~c"03bd9e"
        end
      )
    end

    @tag :skip_env_test_no_nif
    test "option as atom" do
      with_config(%{name: :appsignal_test_suite_app, log: :file, log_level: :trace}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_APP_NAME") == ~c"appsignal_test_suite_app"
        assert Nif.env_get("_APPSIGNAL_LOG") == ~c"file"
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"trace"
      end)
    end

    @tag :skip_env_test_no_nif
    test "option as string" do
      with_config(%{name: "AppSignal test suite app", log: "file", log_level: "trace"}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_APP_NAME") == ~c"AppSignal test suite app"
        assert Nif.env_get("_APPSIGNAL_LOG") == ~c"file"
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"trace"
      end)
    end

    @tag :skip_env_test_no_nif
    test "log_level as warning" do
      with_config(%{log_level: "warning"}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"warn"
      end)
    end

    @tag :skip_env_test_no_nif
    test "deprecated log level configuration" do
      with_config(%{transaction_debug_mode: true}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"trace"
      end)

      with_config(%{debug: true}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"debug"
      end)

      # Default fallback if nothing is configured
      with_config(%{log_level: nil}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_LOG_LEVEL") == ~c"info"
      end)
    end

    test "writes dns_servers to env if empty" do
      with_config(%{dns_servers: []}, fn ->
        write_to_environment()
        assert Nif.env_get("_APPSIGNAL_DNS_SERVERS") == ~c""
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
          files_world_accessible: "false",
          transaction_debug_mode: "false"
        },
        fn ->
          write_to_environment()

          assert Nif.env_get("_APPSIGNAL_ACTIVE") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_DEBUG_LOGGING") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_ENABLE_HOST_METRICS") == ~c"true"
          assert Nif.env_get("_APPSIGNAL_APP_ENV") == ~c"prod"
          assert Nif.env_get("_APPSIGNAL_RUNNING_IN_CONTAINER") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_FILES_WORLD_ACCESSIBLE") == ~c"false"
          assert Nif.env_get("_APPSIGNAL_TRANSACTION_DEBUG_MODE") == ~c"false"
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

        assert Nif.env_get("_APPSIGNAL_CA_FILE_PATH") == ~c""
      end)
    end
  end

  defp default_configuration do
    %{
      active: false,
      ca_file_path: Path.join(:code.priv_dir(:appsignal), "cacert.pem"),
      debug: false,
      diagnose_endpoint: "https://appsignal.com/diag",
      dns_servers: [],
      enable_host_metrics: true,
      enable_minutely_probes: true,
      enable_nginx_metrics: false,
      enable_statsd: false,
      enable_error_backend: true,
      endpoint: "https://push.appsignal.com",
      env: :dev,
      files_world_accessible: true,
      filter_parameters: [],
      filter_session_data: [],
      ignore_actions: [],
      ignore_errors: [],
      ignore_logs: [],
      ignore_namespaces: [],
      log: "file",
      logging_endpoint: "https://appsignal-endpoint.net",
      request_headers: ~w(
        accept accept-charset accept-encoding accept-language cache-control
        connection content-length range
      ),
      send_environment_metadata: true,
      send_params: true,
      send_session_data: true,
      skip_session_data: false,
      transaction_debug_mode: false,
      instrument_absinthe: true,
      instrument_ecto: true,
      instrument_finch: true,
      instrument_oban: true,
      instrument_tesla: true,
      report_oban_errors: "all"
    }
  end

  defp valid_configuration do
    default_configuration()
    |> Map.put(:active, true)
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
