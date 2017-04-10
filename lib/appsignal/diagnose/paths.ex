defmodule Appsignal.Diagnose.Paths do
  def info(config) do
    log_file_path = config[:log_path] || "/tmp/appsignal.log"
    log_dir_path = Path.dirname(log_file_path)
    %{
      log_dir_path: path_report(log_dir_path),
      log_file_path: path_report(log_file_path)
    }
  end

  defp path_report(path) do
    report = %{
      path: path,
      configured: true,
      exists: false,
      writable: false
    }

    path_details =
      if File.exists? path do
        case File.stat(path) do
          {:ok, %{access: access, uid: uid}} ->
            case access do
              p when p in [:write, :read_write] ->
                %{writable: true}
              _ -> %{}
            end
            |> Map.merge(%{ownership: %{uid: uid}})
          {:error, reason} -> %{error: reason}
        end
        |> Map.merge(%{exists: true})
      else
        %{}
      end
    Map.merge(report, path_details)
  end
end
