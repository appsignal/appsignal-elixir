defmodule Mix.Tasks.Appsignal.Install do
  use Mix.Task
  @shortdoc "Installs AppSignal into the current application"

  def run(args) do
    case :os.type() do
      {:win32, _} ->
        """
        We've detected that you're running Windows. Unfortunately, AppSignal does not support Windows at this time.
        """
        |> IO.puts()

        exit(:shutdown)

      _ ->
        do_run(args)
    end
  end

  defp do_run([]) do
    header()

    """
    We're missing an AppSignal Push API key and cannot continue.
    Please supply one as an argument to this command.

      mix appsignal.install push_api_key

    You can find your push_api_key on https://appsignal.com/accounts under 'Add app'
    Contact us at support@appsignal.com if you're stuck.
    """
    |> IO.puts()
  end

  defp do_run([push_api_key]) do
    config = %{otp_app: otp_app(), active: true, push_api_key: push_api_key, request_headers: []}
    Application.put_env(:appsignal, :config, config)
    Appsignal.Config.initialize()

    header()
    validate_push_api_key()
    config = Map.put(config, :name, ask_for_app_name(config))

    case ask_kind_of_configuration() do
      :file ->
        write_config_file(config)
        link_config_file()
        activate_config_for_env("dev")
        activate_config_for_env("stag")
        activate_config_for_env("prod")

      :env ->
        output_config_environment_variables(config)
    end

    if Code.ensure_loaded?(Phoenix) do
      output_phoenix_instructions()
    end

    IO.puts("\nAppSignal installed! 🎉")

    Mix.Tasks.Appsignal.Demo.run([])
  end

  defp otp_app do
    config = Mix.Project.config()
    Keyword.get(config, :app)
  end

  defp header do
    """
    AppSignal install
    #{hr()}
    Website:       https://appsignal.com
    Documentation: http://docs.appsignal.com
    Support:       support@appsignal.com
    #{hr()}

    Welcome to AppSignal!

    This installer will guide you through setting up AppSignal in your application.
    We will perform some checks on your system and ask how you like AppSignal to be
    configured.

    #{hr()}

    """
    |> IO.puts()
  end

  defp hr, do: String.duplicate("=", 80)

  defp validate_push_api_key do
    IO.write("Validating Push API key: ")
    config = Application.get_env(:appsignal, :config)

    case Appsignal.Utils.PushApiKeyValidator.validate(config) do
      :ok ->
        IO.puts("Valid! 🎉")

      {:error, :invalid} ->
        print_invalid()
        exit(:shutdown)

      {:error, reason} ->
        print_validating_error(reason)
        exit(:shutdown)
    end
  end

  defp print_invalid do
    """
    Invalid
    Please make sure you're using the correct push api key from appsignal.com
    Contact us at support@appsignal.com if you're stuck.
    """
    |> IO.puts()
  end

  defp print_validating_error(reason) do
    """

    Validating failed, reason:

      #{inspect(reason)}
    """
    |> IO.puts()
  end

  defp ask_for_app_name(%{otp_app: default}) do
    name = ask_for_input("What is your application's name? [#{default}]")

    if String.length(name) < 1 do
      default
    else
      name
    end
  end

  defp ask_kind_of_configuration do
    """

    There are two methods of configuring AppSignal in your application.
      Option 1: Using a "config/appsignal.exs" file. (1)
      Option 2: Using system environment variables.  (2)
    """
    |> IO.puts()

    case ask_for_input("What is your preferred configuration method? [1]") do
      "1" ->
        :file

      "2" ->
        :env

      input ->
        if String.length(input) < 1 do
          :file
        else
          IO.puts("I'm sorry, I didn't quite get that. Please choose option 1 or 2.")
          ask_kind_of_configuration()
        end
    end
  end

  defp output_config_environment_variables(config) do
    """
    Configuring with environment variables.
    Please put the following variables in your environment to configure AppSignal.

      export APPSIGNAL_OTP_APP="#{config[:otp_app]}"
      export APPSIGNAL_APP_NAME="#{config[:name]}"
      export APPSIGNAL_APP_ENV="prod"
      export APPSIGNAL_PUSH_API_KEY="#{config[:push_api_key]}"
    """
    |> IO.puts()
  end

  defp write_config_file(config) do
    IO.write("Writing config file config/appsignal.exs: ")

    File.mkdir_p("config")

    case File.open(appsignal_config_file_path(), [:write]) do
      {:ok, file} ->
        case binwrite_with_result(file, appsignal_config_file_contents(config)) do
          :ok ->
            IO.puts("Success!")

          {:error, reason} ->
            IO.puts("Failure! #{inspect(reason)}")
            exit(:shutdown)
        end

        File.close(file)

      {:error, reason} ->
        IO.puts("Failure! #{inspect(reason)}")
        exit(:shutdown)
    end
  end

  if Version.match?(System.version(), ">= 1.16.0") do
    defp binwrite_with_result(path, contents) do
      try do
        IO.binwrite(path, contents)
      catch
        {:error, reason} -> {:error, reason}
      end
    end
  else
    defdelegate binwrite_with_result(path, contents), to: IO, as: :binwrite
  end

  # Link the config/appsignal.exs config file to the config/config.exs file.
  # If already linked, it's ignored.
  defp link_config_file do
    IO.write("Linking config to config/config.exs: ")

    active_content = "\nimport_config \"#{appsignal_config_filename()}\"\n"

    cond do
      appsignal_config_linked?() ->
        IO.puts("Success! (Already linked?)")

      File.exists?(config_file_path()) ->
        case append_to_file(config_file_path(), active_content) do
          :ok ->
            IO.puts("Success!")

          {:error, reason} ->
            IO.puts("Failure! #{inspect(reason)}")
            exit(:shutdown)
        end

      true ->
        case File.write(config_file_path(), "import Config\n#{active_content}") do
          :ok ->
            IO.puts("Success!")

          {:error, reason} ->
            IO.puts("Failure! #{inspect(reason)}")
            exit(:shutdown)
        end
    end
  end

  # Checks if AppSignal was already linked in the main config/config.exs file.
  defp appsignal_config_linked? do
    case File.read(config_file_path()) do
      {:ok, contents} ->
        String.contains?(contents, ~s(import_config "#{appsignal_config_filename()})) ||
          String.contains?(contents, "import_config '#{appsignal_config_filename()}")

      {:error, :enoent} ->
        false
    end
  end

  # Contents for the config/appsignal.exs file.
  defp appsignal_config_file_contents(config) do
    options = """
      otp_app: #{inspect(config[:otp_app])},
      name: "#{config[:name]}",
      push_api_key: "#{config[:push_api_key]}",
      env: Mix.env
    """

    options_with_active =
      case has_environment_configuration_files?() do
        false -> "  active: true,\n" <> options
        true -> options
      end

    """
    import Config

    config :appsignal, :config,
    #{options_with_active}
    """
  end

  # Append a line to Mix configuration environment files which activate
  # AppSignal. This is done for development, staging and production
  # environments if they are present.
  defp activate_config_for_env(env) do
    env_file = config_path_for_env(env)

    if File.exists?(env_file) do
      IO.write("Activating #{env} environment: ")

      active_content = "\nconfig :appsignal, :config, active: true\n"

      case file_contains?(env_file, active_content) do
        :ok ->
          IO.puts("Success! (Already active?)")

        {:error, :not_found} ->
          case append_to_file(env_file, active_content) do
            :ok ->
              IO.puts("Success!")

            {:error, reason} ->
              IO.puts("Failure! #{inspect(reason)}")
              exit(:shutdown)
          end

        {:error, reason} ->
          IO.puts("Failure! #{inspect(reason)}")
          exit(:shutdown)
      end
    end
  end

  defp file_contains?(path, contents) do
    case File.read(path) do
      {:ok, file_contents} ->
        case String.contains?(file_contents, contents) do
          true -> :ok
          _ -> {:error, :not_found}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp append_to_file(path, contents) do
    case File.open(path, [:append]) do
      {:ok, file} ->
        result = IO.binwrite(file, contents)
        File.close(file)
        result

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp output_phoenix_instructions do
    """

    AppSignal detected a Phoenix app
      Please follow the following guide to integrate AppSignal in your
      Phoenix application.
      http://docs.appsignal.com/elixir/integrations/phoenix.html
    """
    |> IO.puts()
  end

  defp ask_for_input(prompt) do
    String.trim(IO.gets("#{prompt}: "))
  end

  defp has_environment_configuration_files? do
    "dev" |> config_path_for_env |> File.exists?() or
      "stag" |> config_path_for_env |> File.exists?() or
      "prod" |> config_path_for_env |> File.exists?()
  end

  defp appsignal_config_filename, do: "appsignal.exs"
  defp config_file_path, do: Path.join("config", "config.exs")
  defp appsignal_config_file_path, do: Path.join("config", appsignal_config_filename())
  defp config_path_for_env(env), do: Path.join("config", "#{env}.exs")
end
