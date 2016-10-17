defmodule Appsignal.Config do


  @default_config %{
    debug: false,
    ignore_errors: [],
    ignore_actions: [],
    env: :dev,
    send_params: true,
    endpoint: "https://push.appsignal.com",
    enable_host_metrics: false,
    filter_parameters: nil,
    skip_session_data: false
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
      true ->
        :ok
      false ->
        {:error, :invalid_config}
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
    "APP_REVISION" => :revision,
    "APPSIGNAL_ENVIRONMENT" => :env,
    "APPSIGNAL_PUSH_API_ENDPOINT" => :endpoint,
    "APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH" => :frontend_error_catching_path,
    "APPSIGNAL_FILTER_PARAMETERS" => :filter_parameters,
    "APPSIGNAL_DEBUG" => :debug,
    "APPSIGNAL_LOG_PATH" => :log_path,
    "APPSIGNAL_IGNORE_ERRORS" => :ignore_errors,
    "APPSIGNAL_IGNORE_ACTIONS" => :ignore_actions,
    "APPSIGNAL_HTTP_PROXY" => :http_proxy,
    "APPSIGNAL_RUNNING_IN_CONTAINER" => :running_in_container,
    "APPSIGNAL_WORKING_DIR_PATH" => :working_dir_path,
    "APPSIGNAL_ENABLE_HOST_METRICS" => :enable_host_metrics,
    "APPSIGNAL_SKIP_SESSION_DATA" => :skip_session_data
  }

  @string_keys ~w(APPSIGNAL_PUSH_API_KEY APPSIGNAL_PUSH_API_ENDPOINT APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH APPSIGNAL_HTTP_PROXY APPSIGNAL_LOG_PATH APPSIGNAL_WORKING_DIR_PATH APP_REVISION)
  @bool_keys ~w(APPSIGNAL_ACTIVE APPSIGNAL_DEBUG APPSIGNAL_INSTRUMENT_NET_HTTP APPSIGNAL_ENABLE_FRONTEND_ERROR_CATCHING APPSIGNAL_ENABLE_ALLOCATION_TRACKING APPSIGNAL_ENABLE_GC_INSTRUMENTATION APPSIGNAL_RUNNING_IN_CONTAINER APPSIGNAL_ENABLE_HOST_METRICS APPSIGNAL_SKIP_SESSION_DATA)
  @atom_keys ~w(APPSIGNAL_APP_NAME APPSIGNAL_ENVIRONMENT)
  @string_list_keys ~w(APPSIGNAL_FILTER_PARAMETERS)

  defp load_environment(config, list, converter) do
    list |> Enum.reduce(
      config,
      fn(key, cfg) ->
        value = System.get_env(key)
        if !empty?(value) do
          Map.put(cfg, @env_to_key_mapping[key], converter.(value))
        else
          cfg
        end
      end)
  end

  defp load_from_environment() do
    %{}
    # Heroku is a container based system
    |> Map.put(:running_in_container, System.get_env("DYNO") != nil)
    |> load_environment(@string_keys, &(&1))
    |> load_environment(@bool_keys, &(true?(&1)))
    |> load_environment(@atom_keys, &(String.to_atom(&1)))
    |> load_environment(@string_list_keys, &(String.split(&1, ",")))
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


  @agent_version Poison.decode!(File.read!("agent.json"))["version"]
  @language_integration_version Mix.Project.config[:version]


  defp write_to_environment(config) do
    System.put_env("APPSIGNAL_ACTIVE", Atom.to_string(config[:active]))
    System.put_env("APPSIGNAL_APP_PATH", List.to_string(:code.priv_dir(:appsignal))) # FIXME - app_path should not be necessary
    System.put_env("APPSIGNAL_AGENT_PATH", List.to_string(:code.priv_dir(:appsignal)))
    System.put_env("APPSIGNAL_ENVIRONMENT", Atom.to_string(config[:env]))
    System.put_env("APPSIGNAL_AGENT_VERSION", @agent_version)
    System.put_env("APPSIGNAL_LANGUAGE_INTEGRATION_VERSION", "elixir-" <> @language_integration_version)
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
    unless empty?(config[:revision]) do
      System.put_env("APP_REVISION", config[:revision])
    end
  end

  def get_system_env do
    System.get_env
    |> Enum.filter(
    fn({"APPSIGNAL_" <> _, _}) -> true;
      ({"APP_REVISION", _}) -> true;
      (_) -> false end)
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
