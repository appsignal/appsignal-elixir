defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  require Logger

  @max_retries 5

  def verify_system_architecture() do
    input_arch = :erlang.system_info(:system_architecture)
    case map_arch(input_arch) do
      :unsupported ->
        {:error, {:unsupported, input_arch}}
      arch when is_binary(arch) ->
        {:ok, arch}
    end
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
      unless has_files?() and has_correct_agent_version?() do
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
      else
        :ok
      end
    end
  end

  defp download_and_extract(url, version, checksum) do
    download_file(url, version)
    |> verify_checksum(checksum)
    |> extract
  end

  defp download_file(url, version) do
    filename = "/tmp/appsignal-agent-#{version}.tar.gz"
    case File.exists?(filename) do
      true ->
        filename
      false ->
        Logger.info "Downloading agent release from #{url}"
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
    defp map_arch('x86_64-redhat-linux-gnu' ++ _), do: "x86_64-linux"
    defp map_arch('x86_64-pc-linux-gnu' ++ _), do: "x86_64-linux"
    defp map_arch('x86_64-alpine-linux' ++ _), do: "x86_64-linux"
    defp map_arch('x86_64-unknown-linux' ++ _), do: "x86_64-linux"
    defp map_arch('x86_64-apple-darwin' ++ _), do: "x86_64-darwin"
  end
  defp map_arch(_), do: :unsupported

  defp priv_dir() do
    path = case :code.priv_dir(:appsignal) do
             {:error, :bad_name} ->
               # this happens on initial compilation
               :filename.join(:filename.dirname(String.to_char_list(List.first(Mix.Tasks.Compile.Erlang.manifests))), 'priv')
             path ->
               path
           end
    List.to_string(path)
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
end
