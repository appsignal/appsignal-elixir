defmodule Mix.Tasks.Appsignal.Diagnose do
  use Mix.Task
  alias Appsignal.Config
  alias Appsignal.Diagnose

  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)
  @report Application.get_env(:appsignal, :appsignal_diagnose_report, Appsignal.Diagnose.Report)

  @shortdoc "Starts and tests AppSignal while validating the configuration."

  def run(args) do
    send_report =
      cond do
        is_nil(args) -> nil
        Enum.member?(args, "--send-report") -> :send_report
        Enum.member?(args, "--no-send-report") -> :no_send_report
        true -> nil
      end

    Application.load(:appsignal)
    report = %{process: %{uid: @system.uid}}
    configure_appsignal()
    config_report = Diagnose.Config.config()
    config = config_report[:options]
    report = Map.put(report, :config, config_report)

    header()
    empty_line()

    library_report = Diagnose.Library.info()
    report = Map.put(report, :library, library_report)
    print_library_info(library_report)
    empty_line()

    host_report = Diagnose.Host.info()
    report = Map.put(report, :host, host_report)
    print_host_information(host_report)
    empty_line()

    report =
      case Diagnose.Agent.report() do
        {:ok, agent_report} ->
          print_agent_diagnostics(agent_report)
          Map.put(report, :agent, agent_report)

        {:error, :nif_not_loaded} ->
          IO.puts("Agent diagnostics")
          IO.puts("  Error: Nif not loaded, aborting.\n")
          report

        {:error, raw_report} ->
          IO.puts("Agent diagnostics")
          IO.puts("  Error: Could not parse the agent report:")
          IO.puts("    Output: #{raw_report}\n")
          Map.put(report, :agent, %{output: raw_report})
      end

    print_configuration(config_report)
    empty_line()

    validation_report = Diagnose.Validation.validate(config)
    report = Map.put(report, :validation, validation_report)
    print_validation(validation_report)
    empty_line()

    path_report = Diagnose.Paths.info(config)
    report = Map.put(report, :paths, path_report)
    print_paths(path_report)
    empty_line()

    send_report_to_appsignal_if_agreed_upon(config, report, send_report)
  end

  defp header do
    IO.puts("AppSignal diagnose")
    IO.puts(String.duplicate("=", 80))
    IO.puts("Use this information to debug your configuration.")
    IO.puts("More information is available on the documentation site.")
    IO.puts("http://docs.appsignal.com/")
    IO.puts("Send this output to support@appsignal.com if you need help.")
    IO.puts(String.duplicate("=", 80))
  end

  defp print_library_info(library_report) do
    IO.puts("AppSignal agent")
    IO.puts("  Language: Elixir")
    IO.puts("  Package version: #{library_report[:package_version]}")
    IO.puts("  Agent version: #{library_report[:agent_version]}")
    IO.puts("  Agent architecture: #{library_report[:agent_architecture]}")
    IO.puts("  Nif loaded: #{yes_or_no(library_report[:extension_loaded])}")
  end

  defp print_host_information(host_report) do
    IO.puts("Host information")
    IO.puts("  Architecture: #{host_report[:architecture]}")
    IO.puts("  Elixir version: #{host_report[:language_version]}")
    IO.puts("  OTP version: #{host_report[:otp_version]}")
    IO.puts("  Operating System: #{host_report[:os]}")
    root_user = if host_report[:root], do: "yes (not recommended)", else: "no"
    IO.puts("  root user: #{root_user}")

    if host_report[:heroku] do
      IO.puts("  Heroku: yes")
    end

    IO.puts("  Container: #{yes_or_no(host_report[:running_in_container])}")
  end

  defp configure_appsignal do
    Config.initialize()
    Config.write_to_environment()
  end

  defp print_agent_diagnostics(report) do
    Diagnose.Agent.print(report)
  end

  defp print_configuration(config) do
    IO.puts("Configuration")

    Enum.each(config[:options], fn {key, _} = option ->
      config_label = configuration_option_label(option)
      option_sources = config[:sources]
      sources = sources_for_option(key, option_sources)
      sources_label = configuration_option_source_label(key, sources, option_sources)
      IO.puts("#{config_label}#{sources_label}")
    end)

    IO.puts(
      "\nRead more about how the diagnose config output is rendered\n" <>
        "https://docs.appsignal.com/elixir/command-line/diagnose.html"
    )
  end

  defp configuration_option_label({key, value}) do
    "  #{key}: #{format_value(value)}"
  end

  defp configuration_option_source_label(_, [], _), do: ""

  defp configuration_option_source_label(_, [:default], _), do: ""

  defp configuration_option_source_label(_, sources, _) when length(sources) == 1 do
    " (Loaded from #{Enum.join(sources, ", ")})"
  end

  defp configuration_option_source_label(key, sources, option_sources) do
    max_source_label_length =
      sources
      |> Enum.map(fn source ->
        source
        |> to_string
        |> String.length()
      end)
      |> Enum.max()

    # + 1 to account for the : symbol
    max_source_label_length = max_source_label_length + 1

    sources_label =
      sources
      |> Enum.map(fn source ->
        label = String.pad_trailing("#{source}:", max_source_label_length)
        "      #{label} #{format_value(option_sources[source][key])}"
      end)
      |> Enum.join("\n")

    "\n    Sources:\n#{sources_label}"
  end

  defp sources_for_option(key, sources) do
    [:default, :system, :file, :env]
    |> Enum.map(fn source ->
      if Map.has_key?(sources[source], key) do
        source
      end
    end)
    |> Enum.reject(fn value -> value == nil end)
  end

  defp format_value(value) do
    inspect(value)
  end

  defp print_validation(validation_report) do
    IO.puts("Validation")
    IO.puts("  Push API key: #{validation_report[:push_api_key]}")
  end

  defp print_paths(path_report) do
    IO.puts("Paths")
    labels = Diagnose.Paths.labels()

    Enum.each(path_report, fn {name, path} ->
      print_path(path, Map.fetch!(labels, name))
    end)
  end

  defp print_path(path, label) do
    IO.puts("  #{label}")
    IO.puts("    Path: #{inspect(path[:path])}")

    if path[:exists] do
      IO.puts("    Writable?: #{yes_or_no(path[:writable])}")
      file_uid = path[:ownership][:uid]
      process_uid = @system.uid
      IO.write("    Ownership?: #{yes_or_no(file_uid == process_uid)}")
      IO.puts(" (file: #{file_uid}, process: #{process_uid})")
    else
      IO.puts("    Exists?: no")
    end

    if path[:content] do
      IO.puts("    Contents (last 10 lines):")
      Enum.each(Enum.take(path[:content], -10), &IO.puts/1)
    end

    if path[:error], do: IO.puts("    Error: #{path[:error]}")
  end

  defp send_report_to_appsignal_if_agreed_upon(config, report, send_report) do
    IO.puts("\nDiagnostics report")
    IO.puts("  Do you want to send this diagnostics report to AppSignal?")

    IO.puts(
      "  If you share this report you will be given a link to \n" <>
        "  AppSignal.com to validate the report.\n" <>
        "  You can also contact us at support@appsignal.com\n  with your support token.\n\n"
    )

    answer =
      case send_report do
        :send_report ->
          IO.puts("  Confirmed sending report using --send-report option.")
          true

        :no_send_report ->
          IO.puts("  Not sending report. (Specified with the --no-send-report option.)")
          false

        _ ->
          yes_or_no?("  Send diagnostics report to AppSignal? (Y/n): ")
      end

    case answer do
      true ->
        IO.puts("\n  Transmitting diagnostics report")
        send_report_to_appsignal(config, report)

      false ->
        IO.puts("  Not sending diagnostics report to AppSignal.")
    end
  end

  def send_report_to_appsignal(config, report) do
    case @report.send(config, report) do
      {:ok, support_token} ->
        IO.puts("  Your support token: #{support_token}")
        IO.puts("  View this report:   https://appsignal.com/diagnose/#{support_token}")

      {:error, %{status_code: 200, body: body}} ->
        IO.puts("  Error: Couldn't decode server response.")
        IO.puts("  Response body: #{body}")

      {:error, %{status_code: status_code, body: body}} ->
        IO.puts("  Error: Something went wrong while submitting the report to AppSignal.")
        IO.puts("  Response code: #{status_code}")
        IO.puts("  Response body: #{body}")

      {:error, %{reason: reason}} ->
        IO.puts("  Error: Something went wrong while submitting the report to AppSignal.")
        IO.puts(reason)
    end
  end

  defp empty_line, do: IO.puts("")

  defp yes_or_no(true), do: "yes"
  defp yes_or_no(false), do: "no"

  # Ask for a yes or no input from the user
  defp yes_or_no?(prompt) do
    case IO.gets(prompt) do
      input when is_binary(input) ->
        case String.downcase(String.trim(input)) do
          input when input in ["y", "yes", ""] -> true
          input when input in ["n", "no"] -> false
          _ -> yes_or_no?(prompt)
        end

      :eof ->
        yes_or_no?(prompt)

      {:error, reason} ->
        IO.puts("  Error while reading input: #{reason}")
        yes_or_no?(prompt)
    end
  end
end
