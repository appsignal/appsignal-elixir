defmodule Appsignal.Diagnose.Host do
  @moduledoc false

  @system Application.compile_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Application.compile_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def info do
    {_, os} = :os.type()

    %{
      architecture: to_string(:erlang.system_info(:system_architecture)),
      language_version: System.version(),
      otp_version: System.otp_release(),
      os: os,
      os_distribution: os_distribution(),
      heroku: @system.heroku?(),
      root: @system.root?(),
      running_in_container: @nif.running_in_container?()
    }
  end

  defp os_distribution do
    file_path = "/etc/os-release"

    if File.exists?(file_path) do
      case File.read(file_path) do
        {:ok, contents} ->
          contents

        {:error, reason} ->
          "Error reading #{file_path}: #{reason}"
      end
    else
      ""
    end
  end
end
