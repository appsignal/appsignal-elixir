defmodule Appsignal.Diagnose.FakeInstallationReport do
  @behaviour Appsignal.Diagnose.InstallationReportBehaviour
  use TestAgent, %{download: {:error, :enoent}, install: {:error, :enoent}}

  def read_install do
    if alive?(), do: get(__MODULE__, :install), else: {:error, :enoent}
  end

  def read_download do
    if alive?(), do: get(__MODULE__, :download), else: {:error, :enoent}
  end
end
