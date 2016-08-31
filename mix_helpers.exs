defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  require Logger

  @max_retries 5

  def ensure_downloaded do

    info = Poison.decode!(File.read!("agent.json"))
    arch = map_arch(:erlang.system_info(:system_architecture))
    arch_config = info["triples"][arch]
    version = info["version"]

    System.put_env("LIB_DIR", priv_dir())

    unless has_file("appsignal-agent") and has_file("appsignal.h") and has_file("appsignal_extension.so") do

      File.mkdir_p!(priv_dir())

      download_file(arch_config["download_url"], version)
      |> verify_checksum(arch_config["checksum"])
      |> extract
    else
      :ok
    end
  end

  defp download_file(url, version) do
    filename = :filename.join("/tmp", version <> :filename.basename(url))
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
      raise Mix.Error, message: """
      Checksum verification of #{filename} failed!
      Calculated: #{calculated}
        Expected: #{expected}
      """
    end
    filename
  end

  defp extract(filename) do
    case System.cmd("tar", ["zxf", filename], stderr_to_stdout: true, cd: priv_dir()) do
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
    {result, error_code} = System.cmd("make", [])
    IO.binwrite(result)

    if error_code != 0 do
      raise Mix.Error, message: """
      Could not run `make`. Please check if `make` and either `clang` or `gcc` are installed
      """
    end
    :ok
  end

  defp map_arch('x86_64-unknown-linux' ++ _), do: "x86_64-linux"
  defp map_arch('x86_64-apple-darwin' ++ _), do: "x86_64-darwin"

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

  defp has_file(filename) do
    File.exists?(priv_dir() <> "/" <> filename)
  end

end
