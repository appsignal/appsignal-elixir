defmodule Appsignal.Diagnose.Host do
  @moduledoc false

  require Appsignal.Utils

  @system Appsignal.Utils.compile_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Appsignal.Utils.compile_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def info do
    {_, os} = :os.type()

    %{
      architecture: to_string(:erlang.system_info(:system_architecture)),
      language_version: System.version(),
      otp_version: System.otp_release(),
      os: os,
      heroku: @system.heroku?(),
      root: @system.root?(),
      running_in_container: @nif.running_in_container?()
    }
  end
end
