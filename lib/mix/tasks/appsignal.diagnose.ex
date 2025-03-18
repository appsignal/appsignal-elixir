defmodule Mix.Tasks.Appsignal.Diagnose do
  use Mix.Task
  alias Appsignal.Config
  alias Appsignal.Diagnose

  @system Application.compile_env(:appsignal, :appsignal_system, Appsignal.System)
  @report Application.compile_env(
            :appsignal,
            :appsignal_diagnose_report,
            Appsignal.Diagnose.Report
          )

  @shortdoc "Starts and tests AppSignal while validating the configuration"

  def run(args) do
    send_report =
      cond do
        is_nil(args) -> nil
        Enum.member?(args, "--send-report") -> :send_report
        Enum.member?(args, "--no-send-report") -> :no_send_report
        true -> nil
      end

    Application.load(:appsignal)
    Application.ensure_started(:telemetry)

    report = %{process: %{uid: @system.uid()}}

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

    installation_report = fetch_installation_report()
    report = Map.put(report, :installation, installation_report)
    print_installation_report(installation_report)
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

    path_report = Diagnose.Paths.info()
    report = Map.put(report, :paths, path_report)
    print_paths(path_report)

    send_report_to_appsignal_if_agreed_upon(config, report, send_report)
  end

  defp header do
    IO.puts("AppSignal diagnose")
    IO.puts(String.duplicate("=", 80))
    IO.puts("Use this information to debug your configuration.")
    IO.puts("More information is available on the documentation site.")
    IO.puts("https://docs.appsignal.com/")
    IO.puts("Send this output to support@appsignal.com if you need help.")
    IO.puts(String.duplicate("=", 80))
  end

  defp print_library_info(library_report) do
    IO.puts("AppSignal library")
    IO.puts("  Language: Elixir")
    IO.puts("  Package version: #{format_value(library_report[:package_version])}")
    IO.puts("  Agent version: #{format_value(library_report[:agent_version])}")
    IO.puts("  Nif loaded: #{format_value(library_report[:extension_loaded])}")
  end

  defp fetch_installation_report do
    download_report =
      case do_fetch_installation_report("download") do
        {:ok, report} ->
          report

        {:error, %{"parsing_error" => parsing_report}} ->
          %{"download_parsing_error" => parsing_report}
      end

    install_report =
      case do_fetch_installation_report("install") do
        {:ok, report} ->
          report

        {:error, %{"parsing_error" => parsing_report}} ->
          %{"installation_parsing_error" => parsing_report}
      end

    Map.merge(install_report, download_report)
  end

  defp do_fetch_installation_report(file) do
    case File.read(Path.join([:code.priv_dir(:appsignal), "#{file}.report"])) do
      {:ok, raw_report} ->
        case Jason.decode(raw_report) do
          {:ok, report} ->
            {:ok, report}

          {:error, reason} ->
            {:error, %{"parsing_error" => %{"error" => reason, "raw" => raw_report}}}
        end

      {:error, reason} ->
        {:error, %{"parsing_error" => %{"error" => reason}}}
    end
  end

  defp print_installation_report(report) do
    IO.puts("Extension installation report")
    download_parsing_error = Map.has_key?(report, "download_parsing_error")
    install_parsing_error = Map.has_key?(report, "installation_parsing_error")

    if download_parsing_error && install_parsing_error do
      do_print_parsing_error("download", report)
      do_print_parsing_error("installation", report)
    else
      if install_parsing_error do
        do_print_download_report(report)
        do_print_parsing_error("installation", report)
      else
        do_print_installation_report(report)
      end
    end
  end

  defp do_print_parsing_error(key, report) do
    parsing_report = report["#{key}_parsing_error"]
    IO.puts("  Error found while parsing the #{key} report.")
    IO.puts("  Error: #{inspect(parsing_report["error"])}")

    if Map.has_key?(parsing_report, "raw") do
      IO.puts("  Raw report:\n#{inspect(parsing_report["raw"])}")
    end
  end

  defp do_print_installation_report(installation_report) do
    result_report = installation_report["result"]
    IO.puts("  Installation result")
    IO.puts("    Status: #{result_report["status"]}")

    if Map.has_key?(result_report, "message") do
      IO.puts("    Message: #{format_value(result_report["message"])}")
    end

    if Map.has_key?(result_report, "error") do
      IO.puts("    Error: #{format_value(result_report["error"])}")
    end

    language_report = installation_report["language"]
    IO.puts("  Language details")
    IO.puts("    Elixir version: #{format_value(language_report["version"])}")
    IO.puts("    OTP version: #{format_value(language_report["otp_version"])}")
    do_print_download_report(installation_report)
    build_report = installation_report["build"]
    IO.puts("  Build details")
    IO.puts("    Install time: #{format_value(build_report["time"])}")
    IO.puts("    Source: #{format_value(build_report["source"])}")
    IO.puts("    Agent version: #{format_value(build_report["agent_version"])}")
    IO.puts("    Architecture: #{format_value(build_report["architecture"])}")
    IO.puts("    Target: #{format_value(build_report["target"])}")
    IO.puts("    Musl override: #{build_report["musl_override"]}")
    IO.puts("    Linux ARM override: #{build_report["linux_arm_override"]}")
    IO.puts("    Library type: #{format_value(build_report["library_type"])}")
    IO.puts("    Dependencies: #{format_value(build_report["dependencies"])}")
    IO.puts("    Flags: #{format_value(build_report["flags"])}")
    host_report = installation_report["host"]
    IO.puts("  Host details")
    IO.puts("    Root user: #{format_value(host_report["root_user"])}")
    IO.puts("    Dependencies: #{format_value(host_report["dependencies"])}")
  end

  defp do_print_download_report(%{"download_parsing_error" => %{}} = installation_report) do
    do_print_parsing_error("download", installation_report)
  end

  defp do_print_download_report(installation_report) do
    download_report = installation_report["download"]
    IO.puts("  Download details")
    IO.puts("    Download time: #{format_value(download_report["time"])}")
    IO.puts("    Download URL: #{format_value(download_report["download_url"])}")
    IO.puts("    Architecture: #{format_value(download_report["architecture"])}")
    IO.puts("    Target: #{format_value(download_report["target"])}")
    IO.puts("    Musl override: #{download_report["musl_override"]}")
    IO.puts("    Linux ARM override: #{download_report["linux_arm_override"]}")
    IO.puts("    Library type: #{format_value(download_report["library_type"])}")
    IO.puts("    Checksum: #{format_value(download_report["checksum"])}")
  end

  defp print_host_information(host_report) do
    IO.puts("Host information")
    IO.puts("  Architecture: #{format_value(host_report[:architecture])}")
    IO.puts("  Operating System: #{format_value(host_report[:os])}")
    IO.puts("  Elixir version: #{format_value(host_report[:language_version])}")
    IO.puts("  OTP version: #{format_value(host_report[:otp_version])}")
    root_user = if host_report[:root], do: "true (not recommended)", else: "false"
    IO.puts("  Root user: #{root_user}")

    if host_report[:heroku] do
      IO.puts("  Heroku: true")
    end

    IO.puts("  Running in container: #{format_value(host_report[:running_in_container])}")
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

    # Filter out the diagnose_endpoint config option. Users don't need to see
    # the config option. It's a private config option.
    filtered_options = Enum.reject(config[:options], fn {key, _} -> key == :diagnose_endpoint end)

    filtered_options
    |> Enum.sort()
    |> Enum.each(fn {key, _} = option ->
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
      Enum.map_join(sources, "\n", fn source ->
        label = String.pad_trailing("#{source}:", max_source_label_length)
        "      #{label} #{format_value(option_sources[source][key])}"
      end)

    "\n    Sources:\n#{sources_label}"
  end

  defp sources_for_option(key, sources) do
    [:default, :system, :file, :env, :override]
    |> Enum.map(fn source ->
      if Map.has_key?(sources[source], key) do
        source
      end
    end)
    |> Enum.reject(fn value -> value == nil end)
  end

  defp format_value(value) when is_nil(value), do: "nil"
  defp format_value(value) when is_boolean(value), do: value

  defp format_value(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> format_value
  end

  defp format_value(value), do: inspect(value)

  defp print_validation(validation_report) do
    IO.puts("Validation")
    IO.puts("  Validating Push API key: #{validation_report[:push_api_key]}")
  end

  defp print_paths(path_report) do
    IO.puts("Paths")
    labels = Diagnose.Paths.labels()

    Enum.each(labels, fn {name, label} ->
      print_path(Map.fetch!(path_report, name), label)
    end)
  end

  defp print_path(path, label) do
    IO.puts("  #{label}")
    IO.puts("    Path: #{inspect(path[:path])}")

    if path[:exists] do
      IO.puts("    Writable?: #{format_value(path[:writable])}")
      file_uid = path[:ownership][:uid]
      process_uid = @system.uid()
      IO.write("    Ownership?: #{format_value(file_uid == process_uid)}")
      IO.puts(" (file: #{file_uid}, process: #{process_uid})")
    else
      IO.puts("    Exists?: no")
    end

    if path[:content] do
      IO.puts("    Contents (last 10 lines):")
      Enum.each(Enum.take(path[:content], -10), &IO.puts/1)
    end

    if path[:error], do: IO.puts("    Error: #{path[:error]}")
    empty_line()
  end

  defp send_report_to_appsignal_if_agreed_upon(config, report, send_report) do
    IO.puts("Diagnostics report")
    IO.puts("  Do you want to send this diagnostics report to AppSignal?")

    IO.puts(
      "  If you share this report you will be given a link to \n" <>
        "  AppSignal.com to validate the report.\n" <>
        "  You can also contact us at support@appsignal.com\n  with your support token.\n"
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
        IO.puts("  Transmitting diagnostics report\n")
        send_report_to_appsignal(config, report)

      false ->
        IO.puts("  Not sending diagnostics information to AppSignal.")
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
        IO.puts(inspect(reason))
    end
  end

  defp empty_line, do: IO.puts("")

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
