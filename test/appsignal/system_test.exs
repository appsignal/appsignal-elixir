defmodule Appsignal.SystemTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils

  describe "when not on Heroku" do
    test "returns false" do
      refute Appsignal.System.heroku?
    end
  end

  describe "when on Heroku" do
    setup do: setup_with_env(%{"DYNO" => "1"})

    test "returns true" do
      assert Appsignal.System.heroku?
    end
  end

  describe ".installed_agent_architecture" do
    test "returns nil if the architecture doesn't exist" do
      File.rm(agent_architecture_path())
      assert Appsignal.System.installed_agent_architecture() == nil
    end

    test "returns the architecure if appsignal.architecure exists" do
      File.write(agent_architecture_path(), "x86_64-linux")
      assert Appsignal.System.installed_agent_architecture() == "x86_64-linux"
    end
  end

  defp agent_architecture_path do
    :appsignal
    |> Application.app_dir
    |> Path.join("priv/appsignal.architecture")
  end
end
