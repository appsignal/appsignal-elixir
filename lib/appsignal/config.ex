defmodule Appsignal.Config do


  @default_config %{
    debug: false,
    ignore_errors: [],
    ignore_actions: [],
    send_params: true,
    endpoint: "https://push.appsignal.com",
    enable_host_metrics: false
  }

  @doc """
  Initializes the Appsignal config. Looks at the config default, the
  Elixir-provided configuration and the various `APPSIGNAL_*`
  OS environment variables. Returns whether or not the configuration is valid.
  """
  @spec initialize() :: :ok | {:error, :invalid_config}
  def initialize() do
    app_config = Application.get_env(:appsignal, :config, []) |> coerce_map
    env_config = load_from_environment()

    config = @default_config
    |> Map.merge(app_config)
    |> Map.merge(env_config)

    config = config
    # Config is valid when we have a push api key
    |> Map.put(:valid, !empty?(config[:push_api_key]))
    # Make active by default if the push key is present
    |> Map.put(:active, (if config[:active] == nil, do: !empty?(config[:push_api_key]), else: config[:active]))

    Application.put_env(:appsignal, :config, config)
    write_to_environment(config)

    case config[:valid] do
      true -> :ok
      false -> {:error, :invalid_config}
    end
  end


  @doc """
  Returns whether the Appsignal agent is configured to start on application launch.
  """
  @spec active?() :: boolean
  def active? do
    Application.fetch_env!(:appsignal, :config).active
  end

  @env_to_key_mapping %{
    "APPSIGNAL_ACTIVE" => :active,
    "APPSIGNAL_PUSH_API_KEY" => :push_api_key,
    "APPSIGNAL_APP_NAME" => :name,
    "APPSIGNAL_PUSH_API_ENDPOINT" => :endpoint,
    "APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH" => :frontend_error_catching_path,
    "APPSIGNAL_DEBUG" => :debug,
    "APPSIGNAL_LOG_PATH" => :log_path,
    "APPSIGNAL_IGNORE_ERRORS" => :ignore_errors,
    "APPSIGNAL_IGNORE_ACTIONS" => :ignore_actions,
    "APPSIGNAL_HTTP_PROXY" => :http_proxy,
    "APPSIGNAL_RUNNING_IN_CONTAINER" => :running_in_container,
    "APPSIGNAL_WORKING_DIR_PATH" => :working_dir_path,
    "APPSIGNAL_ENABLE_HOST_METRICS" => :enable_host_metrics
  }

  defp load_from_environment() do
    config = %{}
    # Heroku is a container based system
    |> Map.put(:running_in_container, System.get_env("DYNO") != nil)

    # Configuration with string type
    config = Enum.reduce(
      ~w(APPSIGNAL_PUSH_API_KEY APPSIGNAL_PUSH_API_ENDPOINT APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH APPSIGNAL_HTTP_PROXY APPSIGNAL_LOG_PATH APPSIGNAL_WORKING_DIR_PATH),
      config,
      fn(key, cfg) ->
        value = System.get_env(key)
        if !empty?(value) do
          Map.put(cfg, @env_to_key_mapping[key], value)
        else
          cfg
        end
      end)

    # Configuration with boolean type
    config = Enum.reduce(
      ~w(APPSIGNAL_ACTIVE APPSIGNAL_DEBUG APPSIGNAL_INSTRUMENT_NET_HTTP APPSIGNAL_SKIP_SESSION_DATA APPSIGNAL_ENABLE_FRONTEND_ERROR_CATCHING APPSIGNAL_ENABLE_ALLOCATION_TRACKING APPSIGNAL_ENABLE_GC_INSTRUMENTATION APPSIGNAL_RUNNING_IN_CONTAINER APPSIGNAL_ENABLE_HOST_METRICS),
      config,
      fn(key, cfg) ->
        value = System.get_env(key)
        if !empty?(value) do
          Map.put(cfg, @env_to_key_mapping[key], true?(value))
        else
          cfg
        end
      end)

    # Configuration with atom type
    config = Enum.reduce(
      ~w(APPSIGNAL_APP_NAME),
      config,
      fn(key, cfg) ->
        value = System.get_env(key)
        if !empty?(value) do
          Map.put(cfg, @env_to_key_mapping[key], String.to_atom(value))
        else
          cfg
        end
      end)

    config
  end

  defp coerce_map(value) when is_list(value) do
    value |> Enum.into(%{})
  end
  defp coerce_map(%{} = value) do
    value
  end

  defp empty?(nil), do: true
  defp empty?(""), do: true
  defp empty?(_), do: false

  defp true?("true"), do: true
  defp true?(true), do: true
  defp true?(_), do: false


  defp write_to_environment(config) do
    System.put_env("APPSIGNAL_ACTIVE", Atom.to_string(config[:active]))
    System.put_env("APPSIGNAL_APP_PATH", List.to_string(:code.priv_dir(:appsignal))) # FIXME - app_path should not be necessary
    System.put_env("APPSIGNAL_AGENT_PATH", List.to_string(:code.priv_dir(:appsignal)))
    System.put_env("APPSIGNAL_ENVIRONMENT", Atom.to_string(env))
    System.put_env("APPSIGNAL_AGENT_VERSION", agent_version)
    System.put_env("APPSIGNAL_LANGUAGE_INTEGRATION_VERSION", language_integration_version())
    System.put_env("APPSIGNAL_DEBUG_LOGGING", Atom.to_string(config[:debug]))
    unless empty?(config[:log_path]) do
      System.put_env("APPSIGNAL_LOG_FILE_PATH", config[:log_path])
    end
    System.put_env("APPSIGNAL_PUSH_API_ENDPOINT", config[:endpoint] || "")
    System.put_env("APPSIGNAL_PUSH_API_KEY", config[:push_api_key] || "")
    System.put_env("APPSIGNAL_APP_NAME", Atom.to_string(config[:name]))
    unless empty?(config[:http_proxy]) do
      System.put_env("APPSIGNAL_HTTP_PROXY", config[:http_proxy])
    end
    System.put_env("APPSIGNAL_IGNORE_ACTIONS", config[:ignore_actions] |> Enum.join(","))
    System.put_env("APPSIGNAL_RUNNING_IN_CONTAINER", Atom.to_string(config[:running_in_container]))
    unless empty?(config[:working_dir_path]) do
      System.put_env("APPSIGNAL_WORKING_DIR_PATH", config[:working_dir_path])
    end
    System.put_env("APPSIGNAL_ENABLE_HOST_METRICS", Atom.to_string(config[:enable_host_metrics]))
  end


  @attr Mix.env
  defp env do
    @attr
  end

  @attr Poison.decode!(File.read!("agent.json"))["version"]
  defp agent_version do
    @attr
  end

  @attr Mix.Project.config[:version]
  defp language_integration_version() do
    @attr
  end

end
