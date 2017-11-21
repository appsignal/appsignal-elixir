defmodule Appsignal.SystemTest do
  use ExUnit.Case, async: false

  import Mock
  import AppsignalTest.Utils
  setup do
    FakeOS.start_link
    FakeOS.set(:type, {:unix, :linux})
    :ok
  end

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

  describe ".agent_platform" do
    test "agent_platform returns libc build when the system detection doesn't work" do
      FakeOS.set(:type, {:unix, :linux})
      with_mock System, [:passthrough], [cmd: fn(_, _, _) -> raise "oh no!" end] do
        assert Appsignal.System.agent_platform() == "linux"
      end
    end

    test "returns the musl build when using the APPSIGNAL_BUILD_FOR_MUSL env var" do
      with_env %{"APPSIGNAL_BUILD_FOR_MUSL" => "1"}, fn() ->
        assert Appsignal.System.agent_platform() == "linux-musl"
      end
    end

    test "returns the musl build when on a musl system" do
      FakeOS.set(:type, {:unix, :linux})
      with_mock System, [:passthrough], [
        cmd: fn(_, _, _) -> {"musl libc (x86_64)\nVersion 1.1.16", 1} end
      ] do
        assert Appsignal.System.agent_platform() == "linux-musl"
      end
    end

    test "returns the libc build when on a libc linux system" do
      FakeOS.set(:type, {:unix, :linux})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.15-18+deb8u7) 2.15", 1} end]
        }
      ]) do
        assert Appsignal.System.agent_platform() == "linux"
      end
    end

    test "returns the musl build when on an old libc linux system" do
      FakeOS.set(:type, {:unix, :linux})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.14-18+deb8u7) 2.14", 1} end]
        }
      ]) do
        assert Appsignal.System.agent_platform() == "linux-musl"
      end
    end

    test "returns the musl build when on a very old libc linux system" do
      FakeOS.set(:type, {:unix, :linux})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.5-18+deb8u7) 2.5", 1} end]
        }
      ]) do
        assert Appsignal.System.agent_platform() == "linux-musl"
      end
    end

    test "returns the darwin build when on a darwin system" do
      FakeOS.set(:type, {:unix, :darwin})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd: command not found", 1} end]
        }
      ]) do
        assert Appsignal.System.agent_platform() == "darwin"
      end
    end

    test "returns the darwin build when on a freebsd system" do
      FakeOS.set(:type, {:unix, :freebsd})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd: illegal option -- -", 1} end]
        }
      ]) do
        assert Appsignal.System.agent_platform() == "freebsd"
      end
    end
  end

  describe ".installed_agent_architecture" do
    test "returns nil if the architecture doesn't exist" do
      File.rm(agent_architecture_path)
      assert Appsignal.System.installed_agent_architecture() == nil
    end

    test "returns the architecure if appsignal.architecure exists" do
      File.write(agent_architecture_path, "x86_64-linux")
      assert Appsignal.System.installed_agent_architecture() == "x86_64-linux"
    end
  end

  defp agent_architecture_path do
    :appsignal
    |> Application.app_dir
    |> Path.join("priv/appsignal.architecture")
  end
end
