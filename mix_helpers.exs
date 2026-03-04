unless Code.ensure_loaded?(Appsignal.Agent) do
  {_, _} = Code.eval_file("agent.exs")
end

defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  @erlang Application.compile_env(:appsignal, :erlang, :erlang)
  @os Application.compile_env(:appsignal, :os, :os)
  @finch Application.compile_env(:appsignal, :finch, Finch)
  @agent Application.compile_env(:appsignal, :agent, Appsignal.Agent)
  @extractor Application.compile_env(:appsignal, :extractor, Mix.Appsignal.Helper.Extractor)
  @make Application.compile_env(:appsignal, :make, Mix.Appsignal.Helper.Make)
  @ldd Application.compile_env(:appsignal, :ldd, Mix.Appsignal.Helper.Ldd)
  @root_checker Application.compile_env(:appsignal, :root_checker, Mix.Appsignal.Helper.Root)
  @cached_build Application.compile_env(
                  :appsignal,
                  :cached_build,
                  Mix.Appsignal.Helper.CachedBuild
                )
  @report_writer Application.compile_env(
                   :appsignal,
                   :report_writer,
                   Mix.Appsignal.Helper.ReportWriter
                 )
  @installed_version Application.compile_env(
                       :appsignal,
                       :installed_version,
                       Mix.Appsignal.Helper.InstalledVersion
                     )
  @download_cache Application.compile_env(
                    :appsignal,
                    :download_cache,
                    Mix.Appsignal.Helper.DownloadCache
                  )
  @extension_dir Application.compile_env(
                   :appsignal,
                   :extension_dir,
                   Mix.Appsignal.Helper.ExtensionDir
                 )

  @proxy_env_vars [
    "APPSIGNAL_HTTP_PROXY",
    "https_proxy",
    "HTTPS_PROXY",
    "http_proxy",
    "HTTP_PROXY"
  ]

  require Logger

  def install do
    if Mix.env() == :test_no_nif, do: @extension_dir.prepare!(priv_dir())
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
    arch_config = @agent.triples()[architecture_key]
    System.put_env("LIB_DIR", priv_dir())

    cond do
      has_local_release_files?() ->
        Mix.shell().info("AppSignal: Using local agent release.")
        @extension_dir.prepare!(priv_dir())

        Enum.each(
          ["appsignal.h", "appsignal-agent", "appsignal.version", "libappsignal.a"],
          fn file ->
            File.cp(project_ext_path(file), priv_path(file))
          end
        )

        {:ok, merge_report(report, %{build: %{source: "local"}})}

      @cached_build.installed?(priv_dir(), @agent.version()) ->
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
    version = @agent.version()
    filename = arch_config[:filename]

    @extension_dir.prepare!(priv_dir())

    local_filename = Path.join(tmp_dir(), "appsignal-agent-#{version}.tar.gz")

    case @download_cache.exists?(local_filename) do
      true ->
        {:ok, {local_filename, merge_report(report, %{build: %{source: "cached_in_tmp_dir"}})}}

      false ->
        Mix.shell().info("Downloading agent release")
        {:ok, pid} = @finch.start_link(name: AppsignalFinchDownload)

        try do
          case do_download_file!(filename, local_filename, @agent.mirrors()) do
            {:ok, url} ->
              {:ok, {local_filename, merge_report(report, %{download: %{download_url: url}})}}

            {error, url} ->
              {:error, {error, merge_report(report, %{download: %{download_url: url}})}}
          end
        after
          Process.exit(pid, :normal)
        end
    end
  end

  defp verify_download_package(filename, expected_checksum, report) do
    data = @download_cache.read!(filename)
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
      version = @agent.version()
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
    request =
      @finch.build(:get, url, [], "")
      |> @finch.request(AppsignalFinchDownload, download_options())

    case request do
      {:ok, %{status: 200, body: body}} ->
        @download_cache.write(local_filename, body)

      response ->
        message = """
        - URL: #{url}
        - Error (Finch response):
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
    @extractor.extract(filename, priv_dir())
  end

  defp compile(report) do
    report =
      case agent_version() do
        {:ok, version} -> merge_report(report, %{build: %{agent_version: version}})
        {:error, _} -> report
      end

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
    @make.run(to_string(Mix.env()))
  end

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

    case Map.has_key?(@agent.triples(), arch_key(arch)) do
      true -> {:ok, arch}
      false -> {:error, {:unsupported, arch}}
    end
  end

  defp arch_key({arch, target}) do
    "#{arch}-#{target}"
  end

  defp tmp_dir do
    Application.get_env(:appsignal, :tmp_dir) ||
      case {File.dir?("/tmp"), File.stat("/tmp")} do
        {true, {:ok, %{access: :write}}} -> "/tmp"
        {true, {:ok, %{access: :read_write}}} -> "/tmp"
        _ -> System.tmp_dir!()
      end
  end

  defp priv_path(filename) do
    Path.join(priv_dir(), filename)
  end

  defp project_ext_path(filename) do
    Path.join([__DIR__, "c_src", filename])
  end

  defp has_local_ext_file(filename) do
    filename |> project_ext_path |> File.exists?()
  end

  defp has_local_release_files? do
    has_local_ext_file("appsignal-agent") and has_local_ext_file("appsignal.h") and
      has_local_ext_file("libappsignal.a")
  end

  defp agent_version do
    @installed_version.read(priv_dir())
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
    @ldd.version_output()
  end

  defp extract_ldd_version(ldd_output) when is_binary(ldd_output) do
    case Regex.run(~r/\d+\.\d+/, ldd_output) do
      [version | _tail] -> version
      _ -> nil
    end
  end

  defp extract_ldd_version(_), do: nil

  defp initial_report do
    {_, os} = @os.type()

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
    @report_writer.write_install_report(report)
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

    @report_writer.write_download_report(download_report)
  end

  defp write_download_report(_) do
    # Write nothing if no download details are recorded in the report
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

  def priv_dir do
    Application.get_env(:appsignal, :priv_dir) ||
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
    @root_checker.root?()
  end

  defp serialize_report_value(value) when is_binary(value), do: value
  defp serialize_report_value(value), do: inspect(value)
end

defmodule Mix.Appsignal.Helper.DownloadCache do
  def exists?(path), do: File.exists?(path)
  def write(path, body), do: File.write(path, body)
  def read!(path), do: File.read!(path)
end

defmodule Mix.Appsignal.Helper.ExtensionDir do
  def prepare!(dir) do
    File.mkdir_p!(dir)
    dir |> Path.join("*appsignal*") |> Path.wildcard() |> Enum.each(&File.rm_rf!/1)
  end
end

defmodule Mix.Appsignal.Helper.ReportWriter do
  def write_install_report(report), do: write("install", report)
  def write_download_report(report), do: write("download", report)

  defp write(file, report) do
    dir = Mix.Appsignal.Helper.priv_dir()

    case Jason.encode(report) do
      {:ok, body} ->
        File.mkdir_p!(dir)
        filename = "#{file}.report"
        path = Path.join(dir, filename)

        case File.open(path, [:write]) do
          {:ok, io} ->
            result = IO.binwrite(io, body)
            File.close(io)
            result

          {:error, reason} ->
            Mix.Shell.IO.error("""
            Error: Could not write AppSignal installation report file (#{filename}).

            #{serialize(reason)}
            """)

            {:error, reason}
        end

      {:error, reason} ->
        Mix.Shell.IO.error("""
        Error: Could not encode AppSignal installation report.

        #{serialize(reason)}
        """)

        {:error, reason}
    end
  end

  defp serialize(value) when is_binary(value), do: value
  defp serialize(value), do: inspect(value)
end

defmodule Mix.Appsignal.Helper.CachedBuild do
  def installed?(priv_dir, expected_version) do
    Enum.all?(["appsignal-agent", "appsignal.h", "appsignal_extension.so"], fn file ->
      priv_dir |> Path.join(file) |> File.exists?()
    end) and version_matches?(priv_dir, expected_version)
  end

  defp version_matches?(priv_dir, expected_version) do
    case File.read(Path.join(priv_dir, "appsignal.version")) do
      {:ok, version} -> String.trim(version) == expected_version
      {:error, _} -> false
    end
  end
end

defmodule Mix.Appsignal.Helper.Extractor do
  def extract(filename, dir) do
    case System.cmd("tar", ["zxf", filename, "--no-same-owner"],
           stderr_to_stdout: true,
           cd: dir
         ) do
      {_, 0} ->
        :ok

      {result, _code} ->
        IO.binwrite(result)
        {:error, "Extracting of #{filename} failed!"}
    end
  end
end

defmodule Mix.Appsignal.Helper.Make do
  def run(env) do
    try do
      System.cmd(executable(), args(env), stderr_to_stdout: true)
    rescue
      reason -> {inspect(reason), 1}
    end
  end

  defp executable, do: if(System.find_executable("gmake"), do: "gmake", else: "make")
  defp args("test" <> _), do: ["-e", "CFLAGS_ADD=-DTEST"]
  defp args(_), do: []
end

defmodule Mix.Appsignal.Helper.InstalledVersion do
  def read(priv_dir) do
    case File.read(Path.join(priv_dir, "appsignal.version")) do
      {:ok, version} -> {:ok, String.trim(version)}
      {:error, reason} -> {:error, reason}
    end
  end
end

defmodule Mix.Appsignal.Helper.Ldd do
  def version_output do
    case System.cmd("ldd", ["--version"], stderr_to_stdout: true) do
      {output, _} -> {:ok, output}
    end
  rescue
    exception -> {:error, exception}
  end
end

defmodule Mix.Appsignal.Helper.Root do
  def root? do
    try do
      case System.cmd("id", ["-u"]) do
        {id, 0} ->
          case Integer.parse(List.first(String.split(id, "\n"))) do
            {0, _} -> true
            _ -> false
          end

        _ ->
          false
      end
    catch
      :error, _ -> false
    end
  end
end
