:code.delete(Mix.Appsignal.Helper)
Application.put_env(:appsignal, :erlang, FakeErlang)
Application.put_env(:appsignal, :os, FakeOS)
Application.put_env(:appsignal, :finch, FakeFinchDownload)
Application.put_env(:appsignal, :agent, FakeAgent)
Application.put_env(:appsignal, :extractor, FakeExtractor)
Application.put_env(:appsignal, :make, FakeMake)
Application.put_env(:appsignal, :ldd, FakeLdd)
Application.put_env(:appsignal, :root_checker, FakeRoot)
Application.put_env(:appsignal, :cached_build, FakeCachedBuild)
Application.put_env(:appsignal, :report_writer, FakeReportWriter)
Application.put_env(:appsignal, :installed_version, FakeInstalledVersion)
Application.put_env(:appsignal, :download_cache, FakeDownloadCache)
Application.put_env(:appsignal, :extension_dir, FakeExtensionDir)
{_, _} = Code.eval_file("mix_helpers.exs")

defmodule Mix.Appsignal.HelperTest do
  use ExUnit.Case
  import AppsignalTest.Utils

  setup do
    [
      fake_os: start_supervised!(FakeOS),
      fake_erlang: start_supervised!(FakeErlang),
      fake_finch: start_supervised!(FakeFinchDownload),
      fake_agent: start_supervised!(FakeAgent),
      fake_extractor: start_supervised!(FakeExtractor),
      fake_make: start_supervised!(FakeMake),
      fake_ldd: start_supervised!(FakeLdd),
      fake_cached_build: start_supervised!(FakeCachedBuild),
      fake_report_writer: start_supervised!(FakeReportWriter),
      fake_installed_version: start_supervised!(FakeInstalledVersion),
      fake_download_cache: start_supervised!(FakeDownloadCache)
    ]
  end

  describe ".verify_system_architecture" do
    @tag :skip_env_test_no_nif
    test "returns 64-bit Linux build" do
      report = %{build: %{}}

      assert Mix.Appsignal.Helper.verify_system_architecture(report) == {
               :ok,
               {
                 {"x86_64", "linux"},
                 %{build: %{architecture: "x86_64", target: "linux"}}
               }
             }
    end

    @tag :skip_env_test_no_nif
    test "returns the 64-bit Linux ARM build when using the APPSIGNAL_BUILD_FOR_LINUX_ARM='1' env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_LINUX_ARM" => "1"}, fn ->
        report = %{build: %{}}

        assert Mix.Appsignal.Helper.verify_system_architecture(report) == {
                 :ok,
                 {
                   {"aarch64", "linux"},
                   %{build: %{architecture: "aarch64", target: "linux"}}
                 }
               }
      end)
    end

    @tag :skip_env_test_no_nif
    test "returns the 64-bit Linux ARM build when using the APPSIGNAL_BUILD_FOR_LINUX_ARM='true' env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_LINUX_ARM" => "true"}, fn ->
        report = %{build: %{}}

        assert Mix.Appsignal.Helper.verify_system_architecture(report) == {
                 :ok,
                 {
                   {"aarch64", "linux"},
                   %{build: %{architecture: "aarch64", target: "linux"}}
                 }
               }
      end)
    end
  end

  describe ".agent_platform" do
    test "returns libc build when the system detection doesn't work" do
      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "does not return the musl build when using the APPSIGNAL_BUILD_FOR_MUSL=='' env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_MUSL" => ""}, fn ->
        assert Mix.Appsignal.Helper.agent_platform() != "linux-musl"
      end)
    end

    test "returns the musl build when using the APPSIGNAL_BUILD_FOR_MUSL==1 env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_MUSL" => "1"}, fn ->
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end)
    end

    test "returns the musl build when using the APPSIGNAL_BUILD_FOR_MUSL==true env var" do
      with_env(%{"APPSIGNAL_BUILD_FOR_MUSL" => "true"}, fn ->
        assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
      end)
    end

    test "returns the musl build when on a musl system", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:ok, "musl libc (x86_64)\nVersion 1.1.16"})

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "returns the libc build when on a libc linux system", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:ok, "ldd (Debian GLIBC 2.15-18+deb8u7) 2.15"})

      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "returns the musl build when on an old libc linux system", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:ok, "ldd (Debian GLIBC 2.14-18+deb8u7) 2.14"})

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "returns the musl build when on a very old libc linux system", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:ok, "ldd (Debian GLIBC 2.5-18+deb8u7) 2.5"})

      assert Mix.Appsignal.Helper.agent_platform() == "linux-musl"
    end

    test "returns libc build when ldd doesn't return a version number", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:ok, ""})

      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "defaults to the libc build when ldd fails", %{fake_ldd: fake_ldd} do
      FakeLdd.update(fake_ldd, :result, {:error, :enoent})

      assert Mix.Appsignal.Helper.agent_platform() == "linux"
    end

    test "returns the darwin build when on a darwin system", %{fake_os: fake_os} do
      FakeOS.update(fake_os, :type, {:unix, :darwin})

      assert Mix.Appsignal.Helper.agent_platform() == "darwin"
    end

    test "returns the FreeBSD build when on a FreeBSD system", %{fake_os: fake_os} do
      FakeOS.update(fake_os, :type, {:unix, :freebsd})

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

  describe "install/0 with successful remote download" do
    @tag :skip_env_test_no_nif
    test "install.report has success status, build metadata, and language info" do
      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :success
      assert report[:build][:source] == "remote"
      assert report[:build][:architecture] == "x86_64"
      assert report[:build][:target] == "linux"
      assert report[:build][:library_type] == "static"
      assert report[:build][:agent_version] == "0.0.1-test"
      assert is_binary(report[:build][:time])
      assert report[:language][:name] == "elixir"
      assert is_binary(report[:language][:version])
      assert is_binary(report[:language][:otp_version])
      assert is_boolean(report[:host][:root_user])
    end

    @tag :skip_env_test_no_nif
    test "download.report has verified checksum, URL, and matching build metadata", %{
      fake_finch: fake_finch
    } do
      Mix.Appsignal.Helper.install()

      {_method, requested_url, _headers, _body} = FakeFinchDownload.get(fake_finch, :last_request)

      assert requested_url ==
               "http://fake-mirror/0.0.1-test/appsignal-x86_64-linux-all-static.tar.gz"

      report = FakeReportWriter.get_download_report()
      assert report[:download][:checksum] == "verified"

      assert report[:download][:download_url] ==
               "http://fake-mirror/0.0.1-test/appsignal-x86_64-linux-all-static.tar.gz"

      assert report[:download][:architecture] == "x86_64"
      assert report[:download][:target] == "linux"
      assert report[:download][:library_type] == "static"
      assert is_binary(report[:download][:time])
    end
  end

  describe "install/0 when download HTTP request fails" do
    @tag :skip_env_test_no_nif
    test "install.report has failed status with message", %{fake_finch: fake_finch} do
      FakeFinchDownload.update(fake_finch, :response, {:error, %{reason: :econnrefused}})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:result][:message] =~ "Could not download archive"
    end

    @tag :skip_env_test_no_nif
    test "download.report has unverified checksum", %{fake_finch: fake_finch} do
      FakeFinchDownload.update(fake_finch, :response, {:error, %{reason: :econnrefused}})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_download_report()
      assert report[:download][:checksum] == "unverified"
    end
  end

  describe "install/0 with multiple mirrors when first mirror fails" do
    @tag :skip_env_test_no_nif
    test "falls back to second mirror and installs successfully", %{
      fake_agent: fake_agent,
      fake_finch: fake_finch
    } do
      FakeAgent.update(fake_agent, :mirrors, ["http://failing-mirror", "http://working-mirror"])

      FakeFinchDownload.update(fake_finch, :response_queue, [
        {:error, %{reason: :econnrefused}},
        {:ok, %{status: 200, body: ""}}
      ])

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :success

      download_report = FakeReportWriter.get_download_report()
      assert download_report[:download][:download_url] =~ "working-mirror"
    end

    @tag :skip_env_test_no_nif
    test "install.report has failed status when all mirrors fail", %{
      fake_agent: fake_agent,
      fake_finch: fake_finch
    } do
      FakeAgent.update(fake_agent, :mirrors, ["http://mirror-1", "http://mirror-2"])
      FakeFinchDownload.update(fake_finch, :response, {:error, %{reason: :econnrefused}})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:result][:message] =~ "Could not download archive"
    end
  end

  describe "install/0 when checksum verification fails" do
    @tag :skip_env_test_no_nif
    test "install.report has failed status with checksum message", %{fake_finch: fake_finch} do
      FakeFinchDownload.update(
        fake_finch,
        :response,
        {:ok, %{status: 200, body: "wrong content"}}
      )

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:result][:message] =~ "Checksum verification"
    end

    @tag :skip_env_test_no_nif
    test "download.report has invalid checksum", %{fake_finch: fake_finch} do
      FakeFinchDownload.update(
        fake_finch,
        :response,
        {:ok, %{status: 200, body: "wrong content"}}
      )

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_download_report()
      assert report[:download][:checksum] == "invalid"
    end
  end

  describe "install/0 when tar extraction fails" do
    @tag :skip_env_test_no_nif
    test "install.report has failed status with extraction message", %{
      fake_extractor: fake_extractor
    } do
      FakeExtractor.update(fake_extractor, :result, {:error, "Extracting of archive failed!"})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:result][:message] =~ "Extracting of"
    end

    @tag :skip_env_test_no_nif
    test "both install.report and download.report are written", %{
      fake_extractor: fake_extractor
    } do
      FakeExtractor.update(fake_extractor, :result, {:error, "Extracting of archive failed!"})

      Mix.Appsignal.Helper.install()

      assert FakeReportWriter.get_install_report() != nil
      assert FakeReportWriter.get_download_report() != nil
    end
  end

  describe "install/0 when compilation fails" do
    @tag :skip_env_test_no_nif
    test "install.report has failed status with exit code", %{fake_make: fake_make} do
      FakeMake.update(fake_make, :result, {"make: error\n", 2})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:result][:message] =~ "exit code: 2"
    end

    @tag :skip_env_test_no_nif
    test "both install.report and download.report are written", %{fake_make: fake_make} do
      FakeMake.update(fake_make, :result, {"make: error\n", 2})

      Mix.Appsignal.Helper.install()

      assert FakeReportWriter.get_install_report() != nil
      assert FakeReportWriter.get_download_report() != nil
    end
  end

  describe "install/0 when version file is missing after extraction" do
    @tag :skip_env_test_no_nif
    test "install.report succeeds but omits agent_version", %{
      fake_installed_version: fake_installed_version
    } do
      FakeInstalledVersion.update(fake_installed_version, :result, {:error, :enoent})

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :success
      refute Map.has_key?(report[:build], :agent_version)
    end
  end

  describe "install/0 when architecture is unsupported" do
    @tag :skip_env_test_no_nif
    test "install.report has failed status with architecture in build section", %{
      fake_erlang: fake_erlang
    } do
      FakeErlang.update(fake_erlang, :system_architecture, ~c"i686-pc-linux-gnu")

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :failed
      assert report[:build][:architecture] == "i686"
    end

    @tag :skip_env_test_no_nif
    test "does not write a download.report", %{fake_erlang: fake_erlang} do
      FakeErlang.update(fake_erlang, :system_architecture, ~c"i686-pc-linux-gnu")

      Mix.Appsignal.Helper.install()

      assert FakeReportWriter.get_download_report() == nil
    end
  end

  describe "install/0 when the current version tarball is already in the download cache" do
    @tag :skip_env_test_no_nif
    test "install.report has success status with cached_in_tmp_dir source", %{
      fake_download_cache: fake_download_cache
    } do
      FakeDownloadCache.update(fake_download_cache, :exists, true)

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :success
      assert report[:build][:source] == "cached_in_tmp_dir"
    end

    @tag :skip_env_test_no_nif
    test "download.report has verified checksum and no download URL", %{
      fake_download_cache: fake_download_cache
    } do
      FakeDownloadCache.update(fake_download_cache, :exists, true)

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_download_report()
      assert report[:download][:checksum] == "verified"
      assert report[:download][:download_url] == nil
    end

    @tag :skip_env_test_no_nif
    test "does not make an HTTP request", %{
      fake_download_cache: fake_download_cache,
      fake_finch: fake_finch
    } do
      FakeDownloadCache.update(fake_download_cache, :exists, true)

      Mix.Appsignal.Helper.install()

      assert FakeFinchDownload.get(fake_finch, :last_request) == nil
    end
  end

  describe "install/0 when extension is already cached in priv_dir" do
    @tag :skip_env_test_no_nif
    test "install.report has success status with cached_in_priv_dir source", %{
      fake_cached_build: fake_cached_build
    } do
      FakeCachedBuild.update(fake_cached_build, :result, true)

      Mix.Appsignal.Helper.install()

      report = FakeReportWriter.get_install_report()
      assert report[:result][:status] == :success
      assert report[:build][:source] == "cached_in_priv_dir"
    end

    @tag :skip_env_test_no_nif
    test "does not write a download.report", %{fake_cached_build: fake_cached_build} do
      FakeCachedBuild.update(fake_cached_build, :result, true)

      Mix.Appsignal.Helper.install()

      assert FakeReportWriter.get_download_report() == nil
    end
  end

  describe "CachedBuild.installed?/2" do
    test "returns true when all files exist and version matches" do
      dir = setup_cache_dir("1.2.3", ~w[appsignal-agent appsignal.h appsignal_extension.so])
      assert Mix.Appsignal.Helper.CachedBuild.installed?(dir, "1.2.3")
    end

    test "returns false when version does not match" do
      dir = setup_cache_dir("1.2.3", ~w[appsignal-agent appsignal.h appsignal_extension.so])
      refute Mix.Appsignal.Helper.CachedBuild.installed?(dir, "9.9.9")
    end

    test "returns false when version file is missing" do
      dir = make_tmp_dir()

      Enum.each(~w[appsignal-agent appsignal.h appsignal_extension.so], fn f ->
        File.touch!(Path.join(dir, f))
      end)

      refute Mix.Appsignal.Helper.CachedBuild.installed?(dir, "1.2.3")
    end

    test "returns false when agent files are missing" do
      dir = setup_cache_dir("1.2.3", [])
      refute Mix.Appsignal.Helper.CachedBuild.installed?(dir, "1.2.3")
    end

    test "returns false when only some agent files are present" do
      dir = setup_cache_dir("1.2.3", ~w[appsignal-agent appsignal.h])
      refute Mix.Appsignal.Helper.CachedBuild.installed?(dir, "1.2.3")
    end
  end

  defp setup_cache_dir(version, files) do
    dir = make_tmp_dir()
    File.write!(Path.join(dir, "appsignal.version"), version)
    Enum.each(files, fn f -> File.touch!(Path.join(dir, f)) end)
    dir
  end

  defp make_tmp_dir do
    dir =
      Path.join(System.tmp_dir!(), "appsignal-cache-test-#{:erlang.unique_integer([:positive])}")

    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end
end
