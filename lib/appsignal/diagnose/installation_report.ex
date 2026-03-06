defmodule Appsignal.Diagnose.InstallationReportBehaviour do
  @moduledoc false
  @callback read_install() :: {:ok, binary()} | {:error, atom()}
  @callback read_download() :: {:ok, binary()} | {:error, atom()}
end

defmodule Appsignal.Diagnose.InstallationReport do
  @moduledoc false
  @behaviour Appsignal.Diagnose.InstallationReportBehaviour

  @spec read_install() :: {:ok, binary()} | {:error, atom()}
  def read_install do
    File.read(Path.join([:code.priv_dir(:appsignal), "install.report"]))
  end

  @spec read_download() :: {:ok, binary()} | {:error, atom()}
  def read_download do
    File.read(Path.join([:code.priv_dir(:appsignal), "download.report"]))
  end
end
