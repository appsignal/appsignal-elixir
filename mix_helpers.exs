{_, _} = Code.eval_file("agent.exs")

defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  require Logger

  @max_retries 5

  def verify_system_architecture() do
    input_arch = :erlang.system_info(:system_architecture)
    map_arch(input_arch, agent_platform())
  end

  def ensure_downloaded(arch) do
    arch_config = Appsignal.Agent.triples[arch]

    System.put_env("LIB_DIR", priv_dir())

    if has_local_release_files?() do
      IO.puts "AppSignal: Using local agent release."
      File.rm_rf!(priv_dir())
      File.mkdir_p!(priv_dir())
      Enum.each(["appsignal.h", "appsignal-agent", "appsignal.version", "libappsignal.a"], fn(file) ->
        File.cp(project_ext_path(file), priv_path(file))
      end)
    else
      if has_files?() and has_correct_agent_version?() do
        :ok
      else
        if is_nil(arch_config) do
          raise Mix.Error, message: """
          No config found for architecture '#{arch}'.
          Please check http://docs.appsignal.com/support/operating-systems.html
          And inform us about this error at support@appsignal.com
          """
        end

        version = Appsignal.Agent.version
        File.rm_rf!(priv_dir())
        File.mkdir_p!(priv_dir())

        try do
          download_and_extract(arch_config[:download_url], version, arch_config[:checksum])
        catch
          {:checksum_mismatch, filename, _, _} ->
            File.rm!(filename)
            try do
              download_and_extract(arch_config[:download_url], version, arch_config[:checksum])
            catch
              {:checksum_mismatch, filename, calculated, expected} ->
                raise Mix.Error, message: """
                Checksum verification of #{filename} failed!
                Calculated: #{calculated}
                Expected: #{expected}
                """
            end
        end
      end
    end
  end

  def store_architecture(arch) do
    File.mkdir_p!(priv_dir())
    case File.open priv_path("appsignal.architecture"), [:write] do
      {:ok, file} ->
        result = IO.binwrite(file, arch)
        File.close(file)
        result
      {:error, reason} -> {:error, reason}
    end
  end

  defp download_and_extract(url, version, checksum) do
    download_file(url, version)
    |> verify_checksum(checksum)
    |> extract
  end

  defp download_file(url, version) do
    filename = Path.join(tmp_dir(), "appsignal-agent-#{version}.tar.gz")
    case File.exists?(filename) do
      true ->
        filename
      false ->
        Logger.info "Downloading agent release from #{url}"
        case System.find_executable("curl") do
          nil ->
            raise Mix.Error, message: """
            Could not find the curl executable. Please make sure curl is
            installed on this system as it is needed to download the AppSignal
            extension and agent.
            """
          _ ->
            case System.cmd("curl", ["-s", "-S", "--retry", Integer.to_string(@max_retries), "-f", "-o", filename, url], stderr_to_stdout: true) do
              {_, 0} ->
                filename
              {result, exitcode} ->
                IO.binwrite(result)
                raise Mix.Error, message: """
                Download failed with code #{exitcode}
                """
            end
        end
    end
  end

  defp verify_checksum(filename, expected) do
    data = File.read!(filename)
    calculated = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
    if calculated != expected do
      throw {:checksum_mismatch, filename, calculated, expected}
    end
    filename
  end

  defp extract(filename) do
    case System.cmd("tar", ["zxf", filename, "--no-same-owner"], stderr_to_stdout: true, cd: priv_dir()) do
      {_, 0} ->
        :ok
      {result, _exitcode} ->
        IO.binwrite(result)
        raise Mix.Error, message: """
        Extracting of #{filename} failed!
        """
    end
  end

  def compile do
    {result, error_code} = System.cmd("make", make_args(to_string(Mix.env)))
    IO.binwrite(result)

    if error_code != 0 do
      raise Mix.Error, message: """
      Could not run `make`. Please check if `make` and either `clang` or `gcc` are installed
      """
    end
    :ok
  end

  defp make_args("test" <> _), do: ["-e", "CFLAGS_ADD=-DTEST"]
  defp make_args(_), do: []

  if Mix.env != :test_no_nif do
    defp map_arch('i386-' ++ _, platform), do: build_for("i686", platform)
    defp map_arch('i686-' ++ _, platform), do: build_for("i686", platform)
    defp map_arch('x86-' ++ _, platform), do: build_for("i686", platform)
    defp map_arch('amd64-' ++ _, platform), do: build_for("x86_64", platform)
    defp map_arch('x86_64-' ++ _, platform), do: build_for("x86_64", platform)
  end
  defp map_arch(arch, platform), do: {:error, {:unknown, {arch, platform}}}
  defp build_for(bit, platform) do
    arch = "#{bit}-#{platform}"
    case Map.has_key?(Appsignal.Agent.triples, arch) do
      true -> {:ok, arch}
      false -> {:error, {:unsupported, arch}}
    end
  end

  defp tmp_dir do
    default_tmp_dir = "/tmp"

    case {File.dir?(default_tmp_dir), File.stat(default_tmp_dir)} do
      {true, {:ok, %{access: :write}}} -> default_tmp_dir
      {true, {:ok, %{access: :read_write}}} -> default_tmp_dir
      _ -> System.tmp_dir!
    end
  end


  defp priv_path(filename) do
    Path.join(priv_dir(), filename)
  end

  defp project_ext_path(filename) do
    Path.join([__DIR__, "c_src", filename])
  end

  defp has_file(filename) do
    filename |> priv_path |> File.exists?
  end

  defp has_local_ext_file(filename) do
    filename |> project_ext_path |> File.exists?
  end

  defp has_files? do
    has_file("appsignal-agent") and
    has_file("appsignal.h") and
    has_file("appsignal_extension.so")
  end

  defp has_local_release_files? do
    has_local_ext_file("appsignal-agent") and
    has_local_ext_file("appsignal.h") and
    has_local_ext_file("libappsignal.a")
  end

  defp has_correct_agent_version? do
    path = priv_path("appsignal.version")
    File.read(path) == {:ok, "#{Appsignal.Agent.version}\n"}
  end

  def agent_platform do
    case force_musl_build?() do
      true -> "linux-musl"
      false ->
        case :os.type do
          {:unix, :linux} ->
            agent_platform_by_ldd_version()
          {_, os} ->
            to_string(os)
        end
    end
  end

  def priv_dir() do
    case :code.priv_dir(:appsignal) do
      {:error, :bad_name} ->
        # This happens on initial compilation
        Mix.Tasks.Compile.Erlang.manifests
        |> List.first
        |> Path.dirname
        |> String.trim_trailing(".mix")
        |> Path.join("priv")
      path ->
        path
        |> List.to_string
    end
  end

  defp agent_platform_by_ldd_version do
    try do
      {output, _} = System.cmd("ldd", ["--version"], stderr_to_stdout: true)
      case String.contains?(output, "musl") do
        true -> "linux-musl"
        false ->
          ldd_version = List.first(Regex.run(~r/\d+\.\d+/, output))
          case Version.compare("#{ldd_version}.0", "2.15.0") do
            :lt -> "linux-musl"
            _ -> "linux"
          end
      end
    rescue
      _ -> "linux"
    end
  end

  defp force_musl_build? do
    !is_nil(System.get_env("APPSIGNAL_BUILD_FOR_MUSL"))
  end
end
