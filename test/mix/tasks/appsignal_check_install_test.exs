defmodule Mix.Tasks.Appsignal.CheckInstallTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  defp run do
    Mix.Tasks.Appsignal.CheckInstall.run([])
  end

  describe "when successfully installed" do
    @tag :skip_env_test_no_nif
    test "prints no error" do
      output = capture_io(fn -> run() end)
      assert String.contains?(output, "The AppSignal NIF was successfully installed and loaded.")
    end
  end

  describe "when not installed" do
    @tag :skip_env_test
    test "prints an error" do
      output =
        capture_io(fn ->
          assert catch_exit(run()) == {:shutdown, 1}
        end)

      assert String.contains?(output, "AppSignal failed to load the extension.")
    end
  end
end
