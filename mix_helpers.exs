defmodule Mix.Appsignal.Helper do
  @moduledoc """
  Helper functions for downloading and compiling the AppSignal agent library.
  """

  require Logger

  def ensure_downloaded do

    info = Poison.decode!(File.read!("agent.json"))
    arch = map_arch(:erlang.system_info(:system_architecture))
    arch_config = info["triples"][arch]

    System.put_env("LIB_DIR", priv_dir())
    System.put_env("LIB_NAME", arch_config["libname"])

    unless has_file("appsignal-agent") and has_file("appsignal_extension.h") and has_file(arch_config["libname"]) do

      Logger.info "Downloading agent release from #{arch_config["download_url"]}"

      File.mkdir_p(priv_dir())
      cmd = "cd '#{priv_dir()}' && curl '#{arch_config["download_url"]}' | tar zxf -"
      :os.cmd(String.to_char_list(cmd))

      :ok
    else
      :ok
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
