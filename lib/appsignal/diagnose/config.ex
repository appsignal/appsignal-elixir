defmodule Appsignal.Diagnose.Config do
  alias Appsignal.Config

  def config() do
    sources = Application.get_env(:appsignal, :config_sources, %{})

    %{
      options: Application.get_env(:appsignal, :config),
      sources: sources
    }
  end
end
