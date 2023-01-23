defmodule Appsignal.Utils.Hostname do
  @moduledoc false

  require Appsignal.Utils

  @inet Appsignal.Utils.compile_env(:appsignal, :inet, :inet)

  def hostname do
    case Application.fetch_env(:appsignal, :config) do
      {:ok, %{hostname: hostname}} ->
        hostname

      _ ->
        {:ok, hostname} = @inet.gethostname()
        List.to_string(hostname)
    end
  end
end
