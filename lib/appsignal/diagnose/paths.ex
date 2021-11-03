defmodule Appsignal.Diagnose.Paths do
  @moduledoc false
  def info do
    log_file_path = Appsignal.Config.log_file_path() || "/tmp/appsignal.log"
    log_dir_path = Path.dirname(log_file_path)

    %{
      working_dir: path_report(File.cwd!()),
      log_dir_path: path_report(log_dir_path),
      "appsignal.log": path_report(log_file_path)
    }
  end

  def labels do
    [
      {:working_dir, "Current working directory"},
      {:log_dir_path, "Log directory"},
      {:"appsignal.log", "AppSignal log"}
    ]
  end

  defp path_report(path) do
    report = %{
      path: path,
      exists: false
    }

    path_details =
      if File.exists?(path) do
        result =
          case File.stat(path) do
            {:ok, %{access: access, uid: uid, gid: gid, type: type, mode: mode, size: size}} ->
              r = %{
                writable: file_writable(access),
                type: file_type(type),
                mode: Integer.to_string(mode, 8),
                ownership: %{uid: uid, gid: gid}
              }

              file_result =
                case r[:type] do
                  :file ->
                    case read_file_content(path, size) do
                      {:ok, content} ->
                        %{content: String.split(String.trim_trailing(content), "\n")}

                      {:error, reason} ->
                        %{error: reason}
                    end

                  _ ->
                    %{}
                end

              Map.merge(r, file_result)

            {:error, reason} ->
              %{error: reason}
          end

        Map.merge(result, %{exists: true})
      else
        %{}
      end

    Map.merge(report, path_details)
  end

  # Reads the last bytes of a file
  # The last 2 Mebibytes by default
  defp read_file_content(path, file_size, bytes_to_read \\ 2 * 1024 * 1024) do
    {offset, read_length} =
      if bytes_to_read > file_size do
        # When the file is smaller than the bytes_to_read
        # Read the whole file
        {0, file_size}
      else
        # When the file is smaller than the bytes_to_read
        # Read the last X bytes_to_read
        {file_size - bytes_to_read, bytes_to_read}
      end

    {:ok, file} = :file.open(path, [:read, :binary])
    result = :file.pread(file, offset, read_length)
    :file.close(file)
    result
  end

  defp file_type(type) do
    case type do
      :regular -> :file
      value -> value
    end
  end

  defp file_writable(access) do
    case access do
      p when p in [:write, :read_write] ->
        true

      _ ->
        false
    end
  end
end
