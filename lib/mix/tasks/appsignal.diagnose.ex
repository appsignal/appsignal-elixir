defmodule Mix.Tasks.Appsignal.Diagnose do
  require Logger
  use Mix.Task

  @appsignal_version Mix.Project.config[:version]
  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  @shortdoc "Starts and tests AppSignal while validating the configuration."

  def run(_args) do
    header()
    empty_line()

    agent_version()
    empty_line()

    host_information()
    empty_line()

    load_agent_config()
    start_appsignal_in_diagnose_mode()

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

    IO.puts "  Agent version: #{Appsignal.Agent.version}"
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

  defp load_agent_config do
    unless Code.ensure_loaded?(Appsignal.Agent) do
      {_, _} = Code.eval_file("agent.ex")
    end
  end

  defp start_appsignal_in_diagnose_mode do
    System.put_env "APPSIGNAL_DIAGNOSE", "true"
    {:ok, _} = Application.ensure_all_started(:appsignal)
    Appsignal.stop(nil)
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
    HTTPoison.start
    url = "#{config()[:endpoint]}/1/auth?api_key=#{config()[:push_api_key]}"
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts "  Push API key: valid"
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        IO.puts "  Push API key: invalid"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
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
