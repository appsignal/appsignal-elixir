:code.delete Mix.Appsignal.Helper
Application.put_env(:appsignal, :os, FakeOS)
{_, _} = Code.eval_file("mix_helpers.exs")

defmodule Mix.Appsignal.HelperTest do
  use ExUnit.Case
  import Mock
  import AppsignalTest.Utils

  setup do
    {:ok, fake_os} = FakeOS.start_link
    [fake_os: fake_os]
  end

  describe ".agent_platform" do
    test "agent_platform returns libc build when the system detection doesn't work" do
      with_mock System, [:passthrough], [cmd: fn(_, _, _) -> raise "oh no!" end] do
        assert Mix.Appsignal.Helper.agent_platform() == "linux"
      end
    end

    test "returns the musl build when using the APPSIGNAL_BUILD_FOR_MUSL env var" do
      with_env %{"APPSIGNAL_BUILD_FOR_MUSL" => "1"}, fn() ->
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end
    end

    test "returns the musl build when on a musl system" do
      with_mock System, [:passthrough], [
        cmd: fn(_, _, _) -> {"musl libc (x86_64)\nVersion 1.1.16", 1} end
      ] do
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end
    end

    test "returns the libc build when on a libc linux system" do
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.15-18+deb8u7) 2.15", 1} end]
        }
      ]) do
        assert Mix.Appsignal.Helper.agent_platform() == "linux"
      end
    end

    test "returns the musl build when on an old libc linux system" do
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.14-18+deb8u7) 2.14", 1} end]
        }
      ]) do
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end
    end

    test "returns the musl build when on a very old libc linux system" do
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd (Debian GLIBC 2.5-18+deb8u7) 2.5", 1} end]
        }
      ]) do
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end
    end

    test "returns the darwin build when on a darwin system", %{fake_os: fake_os} do
      FakeOS.update(fake_os, :type, {:unix, :darwin})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd: command not found", 1} end]
        }
      ]) do
        assert Mix.Appsignal.Helper.agent_platform() == "darwin"
      end
    end

    test "returns the darwin build when on a freebsd system", %{fake_os: fake_os} do
      FakeOS.update(fake_os, :type, {:unix, :freebsd})
      with_mocks([
        {System,
          [:passthrough],
          [cmd: fn(_, _, _) -> {"ldd: illegal option -- -", 1} end]
        }
      ]) do
        assert Mix.Appsignal.Helper.agent_platform() == "freebsd"
      end
    end
  end
end
