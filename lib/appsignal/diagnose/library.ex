defmodule Appsignal.Diagnose.Library do
  @appsignal_version Mix.Project.config[:version]
  @agent_version Mix.Project.config[:agent_version]
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def info do
    %{
      language: "elixir",
      agent_version: @agent_version,
      agent_architecture: Appsignal.System.installed_agent_architecture,
      package_version: @appsignal_version,
      extension_loaded: @nif.loaded?
    }
  end
end
