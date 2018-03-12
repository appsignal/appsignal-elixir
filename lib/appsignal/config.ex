defmodule Appsignal.Config do
  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)

  @default_config %{
    active: false,
    debug: false,
    dns_servers: [],
    enable_host_metrics: true,
    endpoint: "https://push.appsignal.com",
    diagnose_endpoint: "https://appsignal.com/diag",
    env: :dev,
    filter_parameters: nil,
    ignore_actions: [],
    ignore_errors: [],
    ignore_namespaces: [],
    send_params: true,
    skip_session_data: false,
    files_world_accessible: true,
    log: "file"
  }

  @doc """
  Initializes the AppSignal config. Looks at the config default, the
  Elixir-provided configuration and the various `APPSIGNAL_*`
  OS environment variables. Returns whether or not the configuration is valid.
  """
  @spec initialize() :: :ok | {:error, :invalid_config}
  def initialize() do
    system_config = load_from_system()
    app_config = Application.get_env(:appsignal, :config, []) |> coerce_map
    env_config = load_from_environment()

    config =
      @default_config
      |> Map.merge(system_config)
      |> Map.merge(app_config)
      |> Map.merge(env_config)

    # Config is valid when we have a push api key
    config =
      config
      |> Map.put(:valid, !empty?(config[:push_api_key]))

    Application.put_env(:appsignal, :config, config)

    case config[:valid] do
      true ->
        :ok

      false ->
        {:error, :invalid_config}
    end
  end

  @doc """
  Returns whether the AppSignal agent is configured to start on application launch.
  """
  @spec active?() :: boolean
  def active? do
    config = Application.fetch_env!(:appsignal, :config)
    config.valid && config.active
  end

  @env_to_key_mapping %{
    "APPSIGNAL_ACTIVE" => :active,
    "APPSIGNAL_PUSH_API_KEY" => :push_api_key,
    "APPSIGNAL_APP_NAME" => :name,
    "APPSIGNAL_APP_ENV" => :env,
    "APPSIGNAL_CA_FILE_PATH" => :ca_file_path,
    "APPSIGNAL_PUSH_API_ENDPOINT" => :endpoint,
    "APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH" => :frontend_error_catching_path,
    "APPSIGNAL_HOSTNAME" => :hostname,
    "APPSIGNAL_FILTER_PARAMETERS" => :filter_parameters,
    "APPSIGNAL_DEBUG" => :debug,
    "APPSIGNAL_DNS_SERVERS" => :dns_servers,
    "APPSIGNAL_LOG" => :log,
    "APPSIGNAL_LOG_PATH" => :log_path,
    "APPSIGNAL_IGNORE_ACTIONS" => :ignore_actions,
    "APPSIGNAL_IGNORE_ERRORS" => :ignore_errors,
    "APPSIGNAL_IGNORE_NAMESPACES" => :ignore_namespaces,
    "APPSIGNAL_HTTP_PROXY" => :http_proxy,
    "APPSIGNAL_RUNNING_IN_CONTAINER" => :running_in_container,
    "APPSIGNAL_WORKING_DIR_PATH" => :working_dir_path,
    "APPSIGNAL_ENABLE_HOST_METRICS" => :enable_host_metrics,
    "APPSIGNAL_SKIP_SESSION_DATA" => :skip_session_data,
    "APPSIGNAL_FILES_WORLD_ACCESSIBLE" => :files_world_accessible
  }

  @string_keys ~w(APPSIGNAL_APP_NAME APPSIGNAL_PUSH_API_KEY APPSIGNAL_PUSH_API_ENDPOINT APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH APPSIGNAL_HOSTNAME APPSIGNAL_HTTP_PROXY APPSIGNAL_LOG APPSIGNAL_LOG_PATH APPSIGNAL_WORKING_DIR_PATH APPSIGNAL_CA_FILE_PATH)
  @bool_keys ~w(APPSIGNAL_ACTIVE APPSIGNAL_DEBUG APPSIGNAL_INSTRUMENT_NET_HTTP APPSIGNAL_ENABLE_FRONTEND_ERROR_CATCHING APPSIGNAL_ENABLE_ALLOCATION_TRACKING APPSIGNAL_ENABLE_GC_INSTRUMENTATION APPSIGNAL_RUNNING_IN_CONTAINER APPSIGNAL_ENABLE_HOST_METRICS APPSIGNAL_SKIP_SESSION_DATA APPSIGNAL_FILES_WORLD_ACCESSIBLE)
  @atom_keys ~w(APPSIGNAL_APP_ENV)
  @string_list_keys ~w(APPSIGNAL_FILTER_PARAMETERS APPSIGNAL_IGNORE_ACTIONS APPSIGNAL_IGNORE_ERRORS APPSIGNAL_IGNORE_NAMESPACES APPSIGNAL_DNS_SERVERS)

  defp load_environment(config, list, converter) do
    list
    |> Enum.reduce(config, fn key, cfg ->
      value = System.get_env(key)

      if !empty?(value) do
        Map.put(cfg, @env_to_key_mapping[key], converter.(value))
      else
        cfg
      end
    end)
  end

  defp load_from_system() do
    config = %{hostname: @system.hostname_with_domain}

    # Make AppSignal active by default if the APPSIGNAL_PUSH_API_KEY
    # environment variable is present.
    # Is overwritten by application config and env config.
    config =
      case System.get_env("APPSIGNAL_PUSH_API_KEY") do
        nil -> config
        _ -> Map.merge(config, %{active: true})
      end

    # Detect Heroku
    case Appsignal.System.heroku?() do
      false -> config
      true -> Map.merge(config, %{running_in_container: true, log: "stdout"})
    end
  end

  defp load_from_environment() do
    %{}
    |> load_environment(@string_keys, & &1)
    |> load_environment(@bool_keys, &true?(&1))
    |> load_environment(@atom_keys, &String.to_atom(&1))
    |> load_environment(@string_list_keys, &String.split(&1, ","))
  end

  defp coerce_map(value) when is_list(value) do
    value |> Enum.into(%{})
  end

  defp coerce_map(%{} = value) do
    value
  end

  defp empty?(nil), do: true
  defp empty?(""), do: true
  defp empty?([]), do: true
  defp empty?(_), do: false

  defp true?("true"), do: true
  defp true?(true), do: true
  defp true?(_), do: false

  @language_integration_version Mix.Project.config()[:version]

  @doc """
  Write the currently known AppSignal configuration to the system environment.
  Must be run before starting the AppSignal agent otherwise it won't know the
  correct configuration.

  ## Example

      case {Appsignal.Config.initialize, Appsignal.Config.active?} do
        {:ok, true} ->
          Appsignal.Config.write_to_environment
          Appsignal.Nif.start
        {:ok, false} ->
          # AppSignal not active
        {{:error, :invalid_config}, _} ->
          # AppSignal has invalid config
      end
  """
  def write_to_environment do
    config = Application.get_env(:appsignal, :config)
    write_to_environment(config)
  end

  defp write_to_environment(config) do
    reset_environment_config!()

    System.put_env("_APPSIGNAL_ACTIVE", to_string(config[:active]))
    System.put_env("_APPSIGNAL_AGENT_PATH", List.to_string(:code.priv_dir(:appsignal)))
    # FIXME - app_path should not be necessary
    System.put_env("_APPSIGNAL_APP_PATH", List.to_string(:code.priv_dir(:appsignal)))

    unless empty?(config[:name]) do
      System.put_env("_APPSIGNAL_APP_NAME", to_string(config[:name]))
    end

    unless empty?(config[:ca_file_path]) do
      System.put_env("_APPSIGNAL_CA_FILE_PATH", config[:ca_file_path])
    end

    System.put_env("_APPSIGNAL_DEBUG_LOGGING", to_string(config[:debug]))

    unless empty?(config[:dns_servers]) do
      System.put_env("_APPSIGNAL_DNS_SERVERS", config[:dns_servers] |> Enum.join(","))
    end

    System.put_env("_APPSIGNAL_ENABLE_HOST_METRICS", to_string(config[:enable_host_metrics]))
    System.put_env("_APPSIGNAL_ENVIRONMENT", to_string(config[:env]))

    unless empty?(config[:filter_parameters]) do
      System.put_env("_APPSIGNAL_FILTER_PARAMETERS", config[:filter_parameters] |> Enum.join(","))
    end

    System.put_env("_APPSIGNAL_HOSTNAME", config[:hostname])

    unless empty?(config[:http_proxy]) do
      System.put_env("_APPSIGNAL_HTTP_PROXY", config[:http_proxy])
    end

    System.put_env("_APPSIGNAL_IGNORE_ACTIONS", config[:ignore_actions] |> Enum.join(","))
    System.put_env("_APPSIGNAL_IGNORE_ERRORS", config[:ignore_errors] |> Enum.join(","))
    System.put_env("_APPSIGNAL_IGNORE_NAMESPACES", config[:ignore_namespaces] |> Enum.join(","))

    System.put_env(
      "_APPSIGNAL_LANGUAGE_INTEGRATION_VERSION",
      "elixir-" <> @language_integration_version
    )

    System.put_env("_APPSIGNAL_LOG", config[:log])

    unless empty?(config[:log_path]) do
      System.put_env("_APPSIGNAL_LOG_FILE_PATH", config[:log_path])
    end

    System.put_env("_APPSIGNAL_PUSH_API_ENDPOINT", config[:endpoint] || "")
    System.put_env("_APPSIGNAL_PUSH_API_KEY", config[:push_api_key] || "")

    unless empty?(config[:running_in_container]) do
      System.put_env("_APPSIGNAL_RUNNING_IN_CONTAINER", to_string(config[:running_in_container]))
    end

    System.put_env("_APPSIGNAL_SEND_PARAMS", to_string(config[:send_params]))

    unless empty?(config[:working_dir_path]) do
      System.put_env("_APPSIGNAL_WORKING_DIR_PATH", config[:working_dir_path])
    end

    unless empty?(config[:files_world_accessible]) do
      System.put_env(
        "_APPSIGNAL_FILES_WORLD_ACCESSIBLE",
        to_string(config[:files_world_accessible])
      )
    end
  end

  @doc """
  Reset the config written to the environment by `write_to_environment/1`.
  This makes sure no existing config gets reused and the configuration for the
  agent gets set again.
  """
  def reset_environment_config! do
    System.get_env()
    |> Enum.filter(fn
      {"_APPSIGNAL_" <> _, _} -> true
      _ -> false
    end)
    |> Enum.each(fn {key, _} ->
      System.delete_env(key)
    end)
  end

  def get_system_env do
    System.get_env()
    |> Enum.filter(fn
      {"APPSIGNAL_" <> _, _} -> true
      _ -> false
    end)
    |> Enum.into(%{})
  end

  # When you use Appsignal.Config you get a handy config macro which
  # can be used to read the application config.
  defmacro __using__(_) do
    quote do
      defmacro config do
        quote do
          Application.get_env(:appsignal, :config, [])
        end
      end
    end
  end
end
