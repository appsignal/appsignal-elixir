defmodule Appsignal.Diagnose.Logs do
  def info do
    path = :appsignal
    |> Application.app_dir
    |> Path.join("install.log")

    install_log = case File.read(path) do
      {:ok, contents} ->
        %{
          path: path,
          exists: true,
          content: contents |> String.split("\n")
        }
      _ -> %{path: path, exists: false}
    end

    %{"install.log": install_log}
  end
end
