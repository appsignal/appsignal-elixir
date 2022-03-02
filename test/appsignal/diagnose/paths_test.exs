defmodule Mix.Tasks.Appsignal.Diagnose.PathsTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Diagnose.Paths

  setup do
    Application.delete_env(:appsignal, :"$log_file_path")
    :ok
  end

  describe "with file bigger than 2 Mebibytes" do
    setup do
      path = System.tmp_dir()
      file_path = Path.join(path, "appsignal.log")
      bytes = more_than_two_mebibytes_of_data()
      File.write!(file_path, bytes)

      on_exit(fn ->
        File.rm!(file_path)
      end)

      {:ok, %{path: path, bytes: bytes}}
    end

    test "only reads the last 2 Mebibytes", %{path: path, bytes: bytes} do
      log =
        with_config(%{log_path: path}, fn ->
          Paths.info()[:"appsignal.log"]
        end)

      bytes_to_read = 2 * 1024 * 1024
      max_length = byte_size(bytes)
      {_, last} = String.split_at(bytes, max_length - bytes_to_read)
      content = Enum.join(log[:content], "\n")
      assert byte_size(bytes) > bytes_to_read
      assert content == last
    end
  end

  describe "with file smaller than 2 Mebibytes" do
    setup do
      path = System.tmp_dir()
      file_path = Path.join(path, "appsignal.log")
      File.write!(file_path, "line 1\nline 2\nline 3")

      on_exit(fn ->
        File.rm!(file_path)
      end)

      {:ok, %{path: path}}
    end

    test "reads the full file", %{path: path} do
      log =
        with_config(%{log_path: path}, fn ->
          Paths.info()[:"appsignal.log"]
        end)

      assert log[:content] == ["line 1", "line 2", "line 3"]
    end
  end

  test "has label definitions for all path reports" do
    path_keys =
      Paths.info()
      |> Map.keys()
      |> MapSet.new()

    label_keys =
      Paths.labels()
      |> Enum.map(fn {key, _value} -> key end)
      |> MapSet.new()

    assert path_keys == label_keys
  end

  defp more_than_two_mebibytes_of_data do
    bytes_length = 2.1 * 1024 * 1024

    bytes_length
    |> round
    |> :crypto.strong_rand_bytes()
    |> :base64.encode_to_string()
    |> to_string
  end
end
