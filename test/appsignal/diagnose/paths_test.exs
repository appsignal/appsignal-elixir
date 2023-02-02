defmodule Mix.Tasks.Appsignal.Diagnose.PathsTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Diagnose.Paths

  setup do
    dir = System.tmp_dir()
    path = Path.join(dir, "appsignal.log")

    Application.delete_env(:appsignal, :"$log_file_path")

    on_exit(fn ->
      File.rm(path)
    end)

    [dir: dir, path: path]
  end

  describe "with file bigger than 2 Mebibytes" do
    setup %{path: path} do
      File.write!(path, more_than_two_mebibytes_of_data())
    end

    test "only reads the last 2 Mebibytes", %{dir: dir} do
      log = with_config(%{log_path: dir}, fn -> Paths.info()[:"appsignal.log"] end)

      assert log[:content]
             |> Enum.join("\n")
             |> byte_size() == 2 * 1024 * 1024
    end
  end

  describe "with file smaller than 2 Mebibytes" do
    setup %{path: path} do
      File.write!(path, "line 1\nline 2\nline 3")
    end

    test "reads the full file", %{dir: dir} do
      log = with_config(%{log_path: dir}, fn -> Paths.info()[:"appsignal.log"] end)

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
