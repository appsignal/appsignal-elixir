:code.delete(Mix.Appsignal.Helper)
Application.put_env(:appsignal, :os, FakeOS)
Application.put_env(:appsignal, :mix_system, FakeSystem)
{_, _} = Code.eval_file("mix_helpers.exs")

defmodule Mix.Appsignal.HelperTest do
  use ExUnit.Case
  import AppsignalTest.Utils

  setup do
    {:ok, fake_system} = FakeSystem.start_link()
    {:ok, fake_os} = FakeOS.start_link()
    [fake_os: fake_os, fake_system: fake_system]
  end

  describe ".agent_platform" do
    test "agent_platform returns libc build when the system detection doesn't work" do
      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "returns the musl build when using the APPSIGNAL_BUILD_FOR_MUSL env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_MUSL" => "1"}, fn ->
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end)
    end

    test "returns the musl build when on a musl system", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"musl libc (x86_64)\nVersion 1.1.16", 0}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "returns the libc build when on a libc linux system", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd (Debian GLIBC 2.15-18+deb8u7) 2.15", 0}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "returns the musl build when on an old libc linux system", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd (Debian GLIBC 2.14-18+deb8u7) 2.14", 0}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "returns the musl build when on a very old libc linux system", %{
      fake_system: fake_system
    } do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd (Debian GLIBC 2.5-18+deb8u7) 2.5", 0}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "defaults to the libc build when ldd fails", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd: command not found", 1}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "returns the darwin build when on a darwin system", %{
      fake_os: fake_os,
      fake_system: fake_system
    } do
      FakeOS.update(fake_os, :type, {:unix, :darwin})

      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd: command not found", 1}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "darwin"
    end

    test "returns the darwin build when on a freebsd system", %{
      fake_os: fake_os,
      fake_system: fake_system
    } do
      FakeOS.update(fake_os, :type, {:unix, :freebsd})

      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"ldd: illegal option -- -", 1}
      end)

      assert Mix.Appsignal.Helper.agent_platform() == "freebsd"
    end
  end

  describe ".check_proxy" do
    test "check_proxy returns nil if there's no proxy defined" do
      assert Mix.Appsignal.Helper.check_proxy(%{}) == nil
    end

    test "check_proxy uses APPSIGNAL_HTTP_PROXY / https_proxy / HTTPS_PROXY / http_proxy / HTTP_PROXY (in that order)" do
      env = %{"HTTP_PROXY" => "MY_HTTP_PROXY"}

      assert Mix.Appsignal.Helper.check_proxy(env) == {"HTTP_PROXY", "MY_HTTP_PROXY"}

      env = Map.put(env, "http_proxy", "my_http_proxy")

      assert Mix.Appsignal.Helper.check_proxy(env) == {"http_proxy", "my_http_proxy"}

      env = %{"HTTPS_PROXY" => "MY_HTTPS_PROXY"}

      assert Mix.Appsignal.Helper.check_proxy(env) == {"HTTPS_PROXY", "MY_HTTPS_PROXY"}

      env = Map.put(env, "https_proxy", "my_https_proxy")

      assert Mix.Appsignal.Helper.check_proxy(env) == {"https_proxy", "my_https_proxy"}

      env = Map.put(env, "APPSIGNAL_HTTP_PROXY", "my_appsignal_proxy")

      assert Mix.Appsignal.Helper.check_proxy(env) ==
               {"APPSIGNAL_HTTP_PROXY", "my_appsignal_proxy"}
    end

    test "check_proxy returns nil if the first found proxy variable is defined but empty" do
      env = %{"APPSIGNAL_HTTP_PROXY" => "", "HTTPS_PROXY" => "MY_HTTPS_PROXY"}

      assert Mix.Appsignal.Helper.check_proxy(env) == nil
    end
  end

  describe "uid/0" do
    test "returns the uid", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        {"999\n", 0}
      end)

      assert Mix.Appsignal.Helper.uid() == 999
    end

    test "nil", %{fake_system: fake_system} do
      FakeSystem.update(fake_system, :cmd, fn _, _, _ ->
        :erlang.raise(:error, :enoent, [])
      end)

      assert Mix.Appsignal.Helper.uid() == nil
    end
  end
end
