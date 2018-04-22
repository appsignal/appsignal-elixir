defmodule Appsignal.SystemTest do
  use ExUnit.Case, async: true
  import Mock
  import AppsignalTest.Utils

  test "hostname_with_domain" do
    with_mocks([
      {:inet_udp, [:unstick], [open: fn(0) -> {:ok, "PORT"} end]},
      {:inet, [:unstick], [gethostname: fn("PORT") -> {:ok, "Alices-MBP.example.com"} end]},
      {:inet_udp, [:unstick], [close: fn("PORT") -> :ok end]}
    ]) do
      assert "Alices-MBP.example.com" == Appsignal.System.hostname_with_domain()
      assert called :inet_udp.close("PORT")
    end
  end

  test "hostname_with_domain, when unable to upen a UDP socket" do
    with_mocks([
      {:inet_udp, [:unstick], [open: fn(0) -> {:error, :eacces} end]}
    ]) do
      assert nil == Appsignal.System.hostname_with_domain()
    end
  end

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
