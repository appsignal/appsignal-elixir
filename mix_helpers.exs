unless Code.ensure_loaded?(Appsignal.Agent) do
  {_, _} = Code.eval_file("agent.exs")
end

defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  @erlang Application.compile_env(:appsignal, :erlang, :erlang)
  @os Application.compile_env(:appsignal, :os, :os)
  @system Application.compile_env(:appsignal, :system, System)

  @proxy_env_vars [
    "APPSIGNAL_HTTP_PROXY",
    "https_proxy",
    "HTTPS_PROXY",
    "http_proxy",
    "HTTP_PROXY"
  ]

  require Logger

  def install do
    report = initial_report()

    case verify_system_architecture(report) do
      {:ok, {arch, report}} ->
        case find_package_source(arch, report) do
          {:ok, {arch_config, %{build: %{source: "remote"}} = report}} ->
            case download_and_compile(arch_config, report) do
              :ok ->
                :ok

              {:error, {reason, report}} ->
                abort_installation(reason, report)
            end

          {:ok, report} ->
            # Installation using already downloaded package of the extension
            compile(report)

          {:error, {reason, report}} ->
            abort_installation(reason, report)
        end

      {:error, {reason, report}} ->
        abort_installation(reason, report)
    end
  end

  @doc """
  Checks to see if a proxy is defined in any of the accepted OS environment
  variables (as per `@proxy_env_vars`).

  Returns `nil` if no proxy is defined, or a `{variable_name, proxy_url}` tuple
  matching the first found variable.

  _NOTE: If the first variable found is defined but empty (""), proxying is
  disabled (eg. `nil` is returned)._
  """
  def check_proxy(environment \\ System.get_env()) do
    Enum.reduce_while(@proxy_env_vars, nil, fn name, acc ->
      if value = Map.get(environment, name) do
        {:halt, proxy_or_nil(name, value)}
      else
        {:cont, acc}
      end
    end)
  end

  defp proxy_or_nil(_, ""), do: nil
  defp proxy_or_nil(name, value), do: {name, value}

  defp find_package_source(arch, report) do
    architecture_key = arch_key(arch)
    arch_config = Appsignal.Agent.triples()[architecture_key]
    System.put_env("LIB_DIR", priv_dir())

    cond do
      has_local_release_files?() ->
        Mix.shell().info("AppSignal: Using local agent release.")
        File.mkdir_p!(priv_dir())
        clean_up_extension_files()

        Enum.each(
          ["appsignal.h", "appsignal-agent", "appsignal.version", "libappsignal.a"],
          fn file ->
            File.cp(project_ext_path(file), priv_path(file))
          end
        )

        {:ok, merge_report(report, %{build: %{source: "local"}})}

      has_files?() and has_correct_agent_version?() ->
        {:ok, merge_report(report, %{build: %{source: "cached_in_priv_dir"}})}

      is_nil(arch_config) ->
        {:error,
         {"No architecture build found for '#{architecture_key}'.",
          merge_report(report, %{build: %{source: "remote"}})}}

      true ->
        {:ok, {arch_config, merge_report(report, %{build: %{source: "remote"}})}}
    end
  end

  defp download_and_compile(arch_config, report) do
    report = merge_report(report, %{download: %{checksum: "unverified"}})

    case download_package(arch_config, report) do
      {:ok, {filename, report}} ->
        case verify_download_package(filename, arch_config[:checksum], report) do
          {:ok, {filename, report}} ->
            case extract_package(filename) do
              :ok ->
                compile(report)

              {:error, reason} ->
                {:error, {reason, report}}
            end

          {:error, {reason, report}} ->
            {:error, {reason, report}}
        end

      {:error, {reason, report}} ->
        {:error, {reason, report}}
    end
  end

  defp download_package(arch_config, report) do
    version = Appsignal.Agent.version()
    filename = arch_config[:filename]

    File.mkdir_p!(priv_dir())
    clean_up_extension_files()

    local_filename = Path.join(tmp_dir(), "appsignal-agent-#{version}.tar.gz")

    case File.exists?(local_filename) do
      true ->
        {:ok, {local_filename, merge_report(report, %{build: %{source: "cached_in_tmp_dir"}})}}

      false ->
        Mix.shell().info("Downloading agent release")
        :application.unset_env(:hackney, :mod_metrics)
        :application.ensure_all_started(:hackney)

        case do_download_file!(filename, local_filename, Appsignal.Agent.mirrors()) do
          {:ok, url} ->
            {:ok, {local_filename, merge_report(report, %{download: %{download_url: url}})}}

          {error, url} ->
            {:error, {error, merge_report(report, %{download: %{download_url: url}})}}
        end
    end
  end

  defp verify_download_package(filename, expected_checksum, report) do
    data = File.read!(filename)
    calculated_checksum = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)

    if calculated_checksum == expected_checksum do
      {:ok, {filename, merge_report(report, %{download: %{checksum: "verified"}})}}
    else
      sub_report = %{download: %{checksum: "invalid"}}

      reason = """
      Checksum verification of #{filename} failed!
      Calculated: #{calculated_checksum}
      Expected: #{expected_checksum}
      """

      {:error, {reason, merge_report(report, sub_report)}}
    end
  end

  defp do_download_file!(filename, local_filename, mirrors) do
    Enum.reduce_while(mirrors, {1, []}, fn mirror, {acc, errors} ->
      version = Appsignal.Agent.version()
      url = build_download_url(mirror, version, filename)
      result = do_download_file!(url, local_filename)

      if result == :ok do
        # Success on download
        {:halt, {:ok, url}}
      else
        if length(mirrors) == acc do
          # All mirrors failed. Write error message detailing all failures
          error_messages =
            Enum.map(Enum.reverse([result | errors]), fn {:error, message} ->
              message
            end)

          message = """
          Could not download archive from any of our mirrors.
          Please make sure your network allows access to any of these mirrors.
          Attempted to download the archive from the following urls:
          #{Enum.join(error_messages, "\n")}
          """

          {:halt, {String.trim(message), url}}
        else
          # Try the next mirror
          {:cont, {acc + 1, [result | errors]}}
        end
      end
    end)
  end

  defp do_download_file!(url, local_filename) do
    case :hackney.request(:get, url, [], "", download_options()) do
      {:ok, 200, _, reference} ->
        case :hackney.body(reference) do
          {:ok, body} -> File.write(local_filename, body)
          {:error, reason} -> {:error, reason}
        end

      response ->
        message = """
        - URL: #{url}
        - Error (hackney response):
        #{inspect(response)}
        """

        {:error, message}
    end
  end

  defp build_download_url(mirror, version, filename) do
    Enum.join([mirror, version, filename], "/")
  end

  defp download_options do
    default_cacert_file_path = priv_path("cacert.pem")

    cacert_file =
      case check_cacert_access(default_cacert_file_path) do
        :ok ->
          default_cacert_file_path

        {:error, message} ->
          Logger.warning(
            "The cacert file path: #{default_cacert_file_path} is not accessible. " <>
              "Reason: #{inspect(message)}. " <>
              "Using system defaults instead."
          )

          :certifi.cacertfile()
      end

    options = [
      ssl_options:
        [
          verify: :verify_peer,
          cacertfile: cacert_file
        ] ++ tls_options() ++ customize_hostname_check_or_verify_fun()
    ]

    case check_proxy() do
      nil ->
        options

      {var, url} ->
        Mix.shell().info("- using proxy from #{var} (#{url})")
        options ++ [proxy: url]
    end
  end

  defp check_cacert_access(cacert_path) do
    case File.stat(cacert_path) do
      {:ok, %{access: access}} when access in [:read, :read_write] ->
        :ok

      {:ok, %{access: access}} ->
        {:error, "File access is #{inspect(access)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_package(filename) do
    case System.cmd("tar", ["zxf", filename, "--no-same-owner"],
           stderr_to_stdout: true,
           cd: priv_dir()
         ) do
      {_, 0} ->
        :ok

      {result, _exitcode} ->
        IO.binwrite(result)
        {:error, "Extracting of #{filename} failed!"}
    end
  end

  defp compile(report) do
    report = merge_report(report, %{build: %{agent_version: agent_version()}})
    {output, exit_code} = run_make()

    if exit_code == 0 do
      Mix.shell().info("AppSignal extension installation successful")
      write_report(merge_report(report, %{result: %{status: :success}}))
      :ok
    else
      message = """
      Build error was encountered while running `make` (exit code: #{exit_code}):

      #{output}
      """

      {:error, {message, report}}
    end
  end

  defp run_make do
    try do
      System.cmd(make(), make_args(to_string(Mix.env())), stderr_to_stdout: true)
    rescue
      reason ->
        {serialize_report_value(reason), 1}
    end
  end

  defp make_args("test" <> _), do: ["-e", "CFLAGS_ADD=-DTEST"]
  defp make_args(_), do: []

  def verify_system_architecture(report) do
    input_arch =
      if force_linux_arm_build?() do
        ~c"aarch64-linux"
      else
        @erlang.system_info(:system_architecture)
      end

    case map_arch(input_arch, agent_platform()) do
      {:ok, {arch, target} = architecture} ->
        sub_report = %{build: %{architecture: arch, target: target}}
        {:ok, {architecture, merge_report(report, sub_report)}}

      {:error, {:unsupported, {arch, target}}} ->
        sub_report = %{build: %{architecture: arch, target: target}}

        reason =
          "Unsupported target platform #{arch} - #{target}, AppSignal " <>
            "integration disabled!\nPlease check " <>
            "http://docs.appsignal.com/support/operating-systems.html"

        {:error, {reason, merge_report(report, sub_report)}}

      {:error, {:unknown, {arch, target}}} ->
        sub_report = %{build: %{architecture: arch, target: target}}

        reason =
          "Unknown target platform #{arch} - #{target}, AppSignal " <>
            "integration disabled!\nPlease check " <>
            "http://docs.appsignal.com/support/operating-systems.html"

        {:error, {reason, merge_report(report, sub_report)}}
    end
  end

  if Mix.env() != :test_no_nif do
    defp map_arch(~c"i386-" ++ _, platform), do: build_for("i686", platform)
    defp map_arch(~c"i686-" ++ _, platform), do: build_for("i686", platform)
    defp map_arch(~c"x86-" ++ _, platform), do: build_for("i686", platform)
    defp map_arch(~c"amd64-" ++ _, platform), do: build_for("x86_64", platform)
    defp map_arch(~c"x86_64-" ++ _, platform), do: build_for("x86_64", platform)
    defp map_arch(~c"aarch64-" ++ _, platform), do: build_for("aarch64", platform)
    defp map_arch(~c"arm-" ++ _, platform), do: build_for("aarch64", platform)
  end

  defp map_arch(arch, platform), do: {:error, {:unknown, {to_string(arch), platform}}}

  defp build_for(bit, platform) do
    arch = {bit, platform}

    case Map.has_key?(Appsignal.Agent.triples(), arch_key(arch)) do
      true -> {:ok, arch}
      false -> {:error, {:unsupported, arch}}
    end
  end

  defp arch_key({arch, target}) do
    "#{arch}-#{target}"
  end

  defp tmp_dir do
    default_tmp_dir = "/tmp"

    case {File.dir?(default_tmp_dir), File.stat(default_tmp_dir)} do
      {true, {:ok, %{access: :write}}} -> default_tmp_dir
      {true, {:ok, %{access: :read_write}}} -> default_tmp_dir
      _ -> System.tmp_dir!()
    end
  end

  defp priv_path(filename) do
    Path.join(priv_dir(), filename)
  end

  defp project_ext_path(filename) do
    Path.join([__DIR__, "c_src", filename])
  end

  defp has_file(filename) do
    filename |> priv_path |> File.exists?()
  end

  defp has_local_ext_file(filename) do
    filename |> project_ext_path |> File.exists?()
  end

  defp has_files? do
    has_file("appsignal-agent") and has_file("appsignal.h") and has_file("appsignal_extension.so")
  end

  defp has_local_release_files? do
    has_local_ext_file("appsignal-agent") and has_local_ext_file("appsignal.h") and
      has_local_ext_file("libappsignal.a")
  end

  defp has_correct_agent_version? do
    agent_version() == Appsignal.Agent.version()
  end

  defp agent_version do
    path = priv_path("appsignal.version")
    {:ok, agent_version} = File.read(path)
    String.trim(agent_version)
  end

  defp clean_up_extension_files do
    priv_dir()
    |> Path.join("*appsignal*")
    |> Path.wildcard()
    |> Enum.each(&File.rm_rf!/1)
  end

  defp library_dependencies do
    case ldd_version_output() do
      {:ok, output} ->
        case extract_ldd_version(output) do
          nil ->
            %{}

          ldd_version ->
            %{libc: ldd_version}
        end

      _ ->
        %{}
    end
  end

  def agent_platform do
    cond do
      force_linux_arm_build?() == true ->
        "linux"

      force_musl_build?() == true ->
        "linux-musl"

      true ->
        case @os.type() do
          {:unix, :linux} ->
            agent_platform_by_ldd_version()

          {_, os} ->
            to_string(os)
        end
    end
  end

  defp agent_platform_by_ldd_version do
    case ldd_version_output() do
      {:ok, output} ->
        case String.contains?(output, "musl") do
          true ->
            "linux-musl"

          false ->
            case extract_ldd_version(output) do
              nil ->
                "linux"

              ldd_version ->
                case Version.compare("#{ldd_version}.0", "2.15.0") do
                  :lt -> "linux-musl"
                  _ -> "linux"
                end
            end
        end

      _ ->
        "linux"
    end
  end

  # Fetches the libc version number from the `ldd` command
  # If `ldd` is not found it returns `nil`
  defp ldd_version_output do
    case @system.cmd("ldd", ["--version"], stderr_to_stdout: true) do
      {output, _} ->
        {:ok, output}
    end
  rescue
    exception ->
      {:error, exception}
  end

  defp extract_ldd_version(ldd_output) when is_binary(ldd_output) do
    case Regex.run(~r/\d+\.\d+/, ldd_output) do
      [version | _tail] -> version
      _ -> nil
    end
  end

  defp extract_ldd_version(_), do: nil

  defp initial_report do
    {_, os} = :os.type()

    %{
      result: %{
        status: :incomplete
      },
      language: %{
        name: "elixir",
        version: System.version(),
        otp_version: System.otp_release()
      },
      build: %{
        time: DateTime.to_iso8601(DateTime.utc_now()),
        package_path: priv_dir(),
        architecture: nil,
        target: os,
        musl_override: force_musl_build?(),
        linux_arm_override: force_linux_arm_build?(),
        library_type: "static",
        dependencies: %{},
        flags: %{}
      },
      host: %{
        root_user: root?(),
        dependencies: library_dependencies()
      }
    }
  end

  defp write_report(report) do
    write_download_report(report)
    write_report_file("install", report)
  end

  defp write_download_report(%{download: %{}} = report) do
    %{
      build: %{
        time: time,
        architecture: architecture,
        target: target,
        musl_override: musl_override,
        linux_arm_override: linux_arm_override,
        library_type: library_type,
        dependencies: %{},
        flags: %{}
      }
    } = report

    %{download: %{checksum: checksum}} = report
    download_url = Map.get(report.download, :download_url)

    download_report = %{
      download: %{
        time: time,
        architecture: architecture,
        target: target,
        musl_override: musl_override,
        linux_arm_override: linux_arm_override,
        library_type: library_type,
        download_url: download_url,
        checksum: checksum || "unverified"
      }
    }

    write_report_file("download", download_report)
  end

  defp write_download_report(_) do
    # Write nothing if no download details are recorded in the report
  end

  defp write_report_file(file, report) do
    case Jason.encode(report) do
      {:ok, body} ->
        File.mkdir_p!(priv_dir())

        filename = "#{file}.report"

        case File.open(priv_path(filename), [:write]) do
          {:ok, file} ->
            result = IO.binwrite(file, body)
            File.close(file)
            result

          {:error, reason} ->
            Mix.Shell.IO.error("""
            Error: Could not write AppSignal installation report file (#{filename}).

            #{serialize_report_value(reason)}
            """)

            {:error, reason}
        end

      {:error, reason} ->
        Mix.Shell.IO.error("""
        Error: Could not encode AppSignal installation report.

        #{serialize_report_value(reason)}
        """)

        {:error, reason}
    end
  end

  defp merge_report(report, %{download: _download_report} = sub_report) do
    key = :download
    {download_report, sub_report} = Map.pop(sub_report, key)
    report = Map.put(report, key, Map.merge(report[key] || %{}, download_report))
    merge_report(report, sub_report)
  end

  defp merge_report(report, %{build: _build_report} = sub_report) do
    key = :build
    {build_report, sub_report} = Map.pop(sub_report, key)
    report = Map.put(report, key, Map.merge(report[key], build_report))
    merge_report(report, sub_report)
  end

  defp merge_report(report, %{result: _installation_report} = sub_report) do
    key = :result
    {installation_report, sub_report} = Map.pop(sub_report, key)
    report = Map.put(report, key, installation_report)
    merge_report(report, sub_report)
  end

  defp merge_report(report, %{}), do: report

  defp abort_installation(reason, report) do
    report =
      merge_report(report, %{result: %{status: :failed, message: serialize_report_value(reason)}})

    write_report(report)
    Mix.Shell.IO.error("AppSignal installation failed: #{serialize_report_value(reason)}")
  end

  defp priv_dir do
    case :code.priv_dir(:appsignal) do
      {:error, :bad_name} ->
        # This happens on initial compilation
        Mix.Tasks.Compile.Erlang.manifests()
        |> List.first()
        |> Path.dirname()
        |> String.trim_trailing(".mix")
        |> Path.join("priv")

      path ->
        path
        |> List.to_string()
    end
  end

  defp force_musl_build? do
    env = System.get_env("APPSIGNAL_BUILD_FOR_MUSL")
    env == "1" || env == "true"
  end

  defp force_linux_arm_build? do
    env = System.get_env("APPSIGNAL_BUILD_FOR_LINUX_ARM")
    env == "1" || env == "true"
  end

  defp make do
    if System.find_executable("gmake"), do: "gmake", else: "make"
  end

  if System.otp_release() >= "23" do
    defp tls_options, do: [versions: :ssl.versions()[:supported]]
  else
    defp tls_options do
      [
        depth: 4,
        ciphers: ciphers(),
        honor_cipher_order: :undefined
      ]
    end

    if System.otp_release() >= "20.3" do
      defp ciphers, do: :ssl.cipher_suites(:default, :"tlsv1.2")
    else
      defp ciphers, do: :ssl.cipher_suites()
    end
  end

  if System.otp_release() >= "21" do
    defp customize_hostname_check_or_verify_fun do
      [
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    end
  else
    defp customize_hostname_check_or_verify_fun do
      [
        verify_fun:
          {fn
             _, :valid, state -> {:valid, state}
             _, :valid_peer, state -> {:valid, state}
             _, {:extension, _}, state -> {:unknown, state}
             _, reason, _ -> {:fail, reason}
           end, self()}
      ]
    end
  end

  def root? do
    uid() == 0
  end

  def uid do
    try do
      case @system.cmd("id", ["-u"]) do
        {id, 0} ->
          case Integer.parse(List.first(String.split(id, "\n"))) do
            {int, _} -> int
            :error -> nil
          end

        {_, _} ->
          nil
      end
    catch
      :error, _ ->
        nil
    end
  end

  defp serialize_report_value(value) when is_binary(value), do: value
  defp serialize_report_value(value), do: inspect(value)
end
