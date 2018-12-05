defmodule Mix.Tasks.Appsignal.Diagnose.PathsTest do
  use ExUnit.Case
  alias Appsignal.Diagnose.Paths

  describe "with file bigger than 2 Mebibytes" do
    setup do
      path = Path.join(System.tmp_dir(), "appsignal_test_file")
      bytes = more_than_two_mebibytes_of_data()
      File.write!(path, bytes)

      on_exit(fn ->
        File.rm!(path)
      end)

      {:ok, %{path: path, bytes: bytes}}
    end

    test "only reads the last 2 Mebibytes", %{path: path, bytes: bytes} do
      paths = Paths.info(%{log_path: path})
      log = paths[:"appsignal.log"]

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
      path = Path.join(System.tmp_dir(), "appsignal_test_file")
      File.write!(path, "line 1\nline 2\nline 3")

      on_exit(fn ->
        File.rm!(path)
      end)

      {:ok, %{path: path}}
    end

    test "reads the full file", %{path: path} do
      paths = Paths.info(%{log_path: path})
      log = paths[:"appsignal.log"]

      assert log[:content] == ["line 1", "line 2", "line 3"]
    end
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
