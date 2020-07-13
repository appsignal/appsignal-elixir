defmodule Appsignal.Utils.FileSystem do
  @moduledoc false

  def system_tmp_dir do
    {_, os_type} = :os.type()
    system_tmp_dir_for_os(os_type)
  end

  @doc false
  def system_tmp_dir_for_os(os_type) do
    case os_type do
      :nt ->
        System.tmp_dir()

      _ ->
        path = "/tmp"

        case File.exists?(path) do
          true ->
            path

          false ->
            System.tmp_dir()
        end
    end
  end

  def writable?(path) do
    case File.stat(path) do
      {:ok, %{access: access}} when access in [:write, :read_write] ->
        true

      _ ->
        false
    end
  end
end
