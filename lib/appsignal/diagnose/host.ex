defmodule Appsignal.Diagnose.Host do
  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def info do
    %{
      architecture: to_string(:erlang.system_info(:system_architecture)),
      language_version: System.version(),
      otp_version: System.otp_release(),
      heroku: @system.heroku?,
      root: @system.root?,
      running_in_container: @nif.running_in_container?
    }
  end
end
