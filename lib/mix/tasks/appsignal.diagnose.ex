defmodule Mix.Tasks.Appsignal.Diagnose do
  use Mix.Task
  alias Appsignal.Utils.PushApiKeyValidator
  alias Appsignal.Config

  @appsignal_version Mix.Project.config[:version]
  @agent_version Mix.Project.config[:agent_version]
  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  @shortdoc "Starts and tests AppSignal while validating the configuration."

  defmodule AgentReport do
    @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

    # Start AppSignal as usual, in diagnose mode, so that it exits early, but
    # does go through the whole process of setting the config to the
    # environment.
    def run do
      IO.puts "Agent diagnostics"
      if @nif.loaded? do
        System.put_env("_APPSIGNAL_DIAGNOSE", "true")
        report_string = @nif.diagnose
        case Poison.decode(report_string) do
          {:ok, report} -> print_report report
          {:error, _} ->
            IO.puts "  Error: Could not parse the agent report:"
            IO.puts "    Output: #{report_string}"
        end
        System.delete_env("_APPSIGNAL_DIAGNOSE")
      else
        IO.puts "  Error: Nif not loaded, aborting."
      end
      IO.puts ""
    end

    defp print_report(report) do
      Enum.each(report_definition(), fn({component, categories}) ->
        print_component(report[component] || %{}, categories)
      end)
    end

    defp print_component(report, categories) do
      Enum.each(categories, fn({category, tests}) ->
        print_category(report[category] || %{}, tests)
      end)
    end

    defp print_category(report, tests) do
      Enum.each(tests, fn({test, definition}) ->
        print_test(report[test] || %{}, definition)
      end)
    end

    defp print_test(report, definition) do
      IO.write "  #{definition[:label]}: "
      case Map.fetch(definition[:values], report["result"]) do
        {:ok, value} -> IO.puts value
        :error -> IO.puts "-"
      end
      if report["error"], do: IO.puts "    Error: #{report["error"]}"
      if report["output"], do: IO.puts "    Output: #{report["output"]}"
    end

    defp report_definition do
      %{
        "extension" => %{
          "config" => %{
            "valid" => %{
              :label => "Extension config",
              :values => %{ true => "valid", false => "invalid" }
            }
          }
        },
        "agent" => %{
          "boot" => %{
            "started" => %{
              :label => "Agent started",
              :values => %{ true => "started", false => "not started" }
            }
          },
          "config" => %{
            "valid" => %{
              :label => "Agent config",
              :values => %{ true => "valid", false => "invalid" }
            }
          },
          "logger" => %{
            "started" => %{
              :label => "Agent logger",
              :values => %{ true => "started", false => "not started" }
            }
          },
          "lock_path" => %{
            "created" => %{
              :label => "Agent lock path",
              :values => %{ true => "writable", false => "not writable" }
            }
          }
        }
      }
    end
  end

  def run(_args) do
    header()
    empty_line()

    agent_version()
    empty_line()

    host_information()
    empty_line()

    configure_appsignal()
    run_agent_diagnose_mode()

    configuration()
    empty_line()

    validate_push_api_key()
    empty_line()

    paths()
  end

  defp header do
    IO.puts "AppSignal diagnose"
    IO.puts String.duplicate("=", 80)
    IO.puts "Use this information to debug your configuration."
    IO.puts "More information is available on the documentation site."
    IO.puts "http://docs.appsignal.com/"
    IO.puts "Send this output to support@appsignal.com if you need help."
    IO.puts String.duplicate("=", 80)
  end

  defp agent_version do
    IO.puts "AppSignal agent"
    IO.puts "  Language: Elixir"
    IO.puts "  Package version: #{@appsignal_version}"

    IO.puts "  Agent version: #{@agent_version}"
    IO.puts "  Nif loaded: #{yes_or_no(@nif.loaded?)}"
  end

  defp host_information do
    IO.puts "Host information"
    IO.puts "  Architecture: #{:erlang.system_info(:system_architecture)}"
    IO.puts "  Elixir version: #{System.version}"
    IO.puts "  OTP version: #{System.otp_release}"
    root_user = if (@system.root?), do: "yes (not recommended)", else: "no"
    IO.puts "  root user: #{root_user}"
    if @system.heroku? do
      IO.puts "  Heroku: yes"
    end
    IO.puts "  Container: #{yes_or_no(@nif.running_in_container?)}"
  end

  defp configure_appsignal do
    Config.initialize
    Config.write_to_environment
  end

  defp run_agent_diagnose_mode do
    AgentReport.run
  end

  defp configuration do
    IO.puts "Configuration"

    Enum.each config(), fn({key, value}) ->
      IO.puts "  #{key}: #{value}"
    end
  end

  defp paths do
    IO.puts "Paths"
    log_file_path = config()[:log_path] || "/tmp/appsignal.log"
    log_dir_path = Path.dirname(log_file_path)

    diagnose_path "log_dir_path", log_dir_path
    diagnose_path "log_file_path", log_file_path
  end

  defp diagnose_path(name, path) do
    IO.puts "  #{name}: #{path}"
    process_uid = @system.uid

    if File.exists? path do
      case File.stat(path) do
        {:ok, %{access: access, uid: uid}} ->
          IO.write "    - Writable?: "
          case access do
            p when p in [:write, :read_write] ->
              IO.puts "yes"
            _ ->
              IO.puts "no"
          end

          IO.write "    - Ownership?: "
          IO.write yes_or_no(uid == process_uid)
          IO.puts " (file: #{uid}, process: #{process_uid})"
        {:error, reason} ->
          IO.puts "    Can't read path: #{reason}"
      end
    else
      IO.puts "    - Exists?: no"
    end
  end

  defp validate_push_api_key do
    IO.puts "Validation"
    IO.write "  Push API key: "
    case PushApiKeyValidator.validate(config()) do
      :ok -> IO.puts "valid"
      {:error, :invalid} -> IO.puts "invalid"
      {:error, reason} -> IO.puts "failure: #{reason}"
    end
  end

  defp config do
    Application.get_env(:appsignal, :config)
  end

  defp empty_line do
    IO.puts ""
  end

  defp yes_or_no(true), do: "yes"
  defp yes_or_no(false), do: "no"
end
