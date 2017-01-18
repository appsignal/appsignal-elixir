defmodule Mix.Tasks.Appsignal.DiagnoseTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  defp run do
    capture_io(fn -> Mix.Tasks.Appsignal.Diagnose.run(nil) end)
  end

  setup do
    original_config = appsignal_config()

    # By default, Push API key is valid
    bypass = Bypass.open
    appsignal_config %{endpoint: "http://localhost:#{bypass.port}"}
    Bypass.expect bypass, fn conn ->
      assert "/1/auth" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "")
    end

    on_exit :reset_config, fn ->
      Application.put_env(:appsignal, :config, original_config)
    end

    {:ok, %{bypass: bypass}}
  end

  test "outputs AppSignal support header" do
    output = run()
    assert String.contains? output, "AppSignal diagnose"
    assert String.contains? output, "http://docs.appsignal.com/"
    assert String.contains? output, "support@appsignal.com"
  end

  test "outputs agent version numbers" do
    output = run()
    assert String.contains? output, "AppSignal agent"
    assert String.contains? output, "Language: Elixir"
    assert String.contains? output, "Package version: #{Appsignal.Mixfile.project[:version]}"

    agent_info = Poison.decode!(File.read!("agent.json"))
    agent_version = agent_info["version"]
    assert agent_version
    assert String.contains? output, "Agent version: #{agent_version}"
  end

  @tag :pending
  describe "when Nif is loaded" do
    test "outputs that the Nif is loaded" do
      output = run()
      assert String.contains? output, "Nif loaded: yes"
    end
  end

  @tag :pending
  describe "when Nif is not loaded" do
    test "outputs that the Nif is not loaded" do
      output = run()
      assert String.contains? output, "Nif loaded: no"
    end
  end

  test "outputs host information" do
    output = run()
    assert String.contains? output, "Host information"
    assert String.contains? output, "Architecture: #{:erlang.system_info(:system_architecture)}"
    assert String.contains? output, "Elixir version: #{System.version}"
    assert String.contains? output, "OTP version: #{System.otp_release}"
    assert String.contains? output, "Process user: #{System.get_env("USER")}"
    refute String.contains? output, "Heroku:"
  end

  describe "when on Heroku" do
    setup do
      System.put_env "DYNO", "1"
      on_exit fn ->
        System.delete_env "DYNO"
      end
    end

    test "outputs Heroku: yes" do
      output = run()
      assert String.contains? output, "Heroku: yes"
    end
  end

  @tag :pending
  describe "when root user" do
    test "outputs warning about running as root" do
      output = run()
      assert String.contains? output, "root user: yes (not recommended)"
    end
  end

  @tag :pending
  describe "when not root user" do
    test "outputs root user: no" do
      output = run()
      assert String.contains? output, "root user: no"
    end
  end

  @tag :pending
  test "runs agent in diagnose mode" do
    output = run()
    assert String.contains? output, "Agent diagnostics"
    assert String.contains? output, "Running agent in diagnose mode"
    assert String.contains? output, "Valid config present"
    assert String.contains? output, "Logger initialized successfully"
    assert String.contains? output, "Lock path is writable"
    assert String.contains? output, "Agent diagnose finished"
  end

  test "outputs configuration" do
    output = run()
    assert String.contains? output, "Configuration"

    Enum.each Application.get_env(:appsignal, :config), fn({key, value}) ->
      assert String.contains? output, "  #{key}: #{value}"
    end
  end

  describe "with valid Push API key" do
    test "outputs invalid API key warning" do
      output = run()
      assert String.contains? output, "Validation"
      assert String.contains? output, "Push API key: valid"
    end
  end

  describe "with invalid Push API key" do
    setup %{bypass: bypass} do
      appsignal_config %{push_api_key: ""}
      Bypass.expect bypass, fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 401, "")
      end
    end

    test "outputs invalid API key warning" do
      output = run()
      assert String.contains? output, "Validation"
      assert String.contains? output, "Push API key: invalid"
    end
  end

  describe "without config" do
    test "it outputs tmp dir for log_dir_path" do
      appsignal_config %{log_path: nil}
      output = run()
      assert String.contains? output, "Paths"
      assert String.contains? output, "log_dir_path: /tmp"
      assert String.contains? output, "log_file_path: /tmp/appsignal.log"
    end
  end

  describe "when log_dir_path is writable" do
    setup do
      log_dir_path = Path.expand("tmp/writable_path", File.cwd!)
      log_file_path = Path.expand("appsignal.log", log_dir_path)
      on_exit :clean_up, fn ->
        File.rm_rf!(log_dir_path)
      end
      File.mkdir_p!(log_dir_path)
      appsignal_config %{log_path: log_file_path}

      {:ok, %{log_dir_path: log_dir_path, log_file_path: log_file_path}}
    end

    test "outputs writable", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      File.touch!(log_file_path)
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes"
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Writable?: yes"
    end

    test "when log file doesn't exist, outputs exists: false", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes"
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Exists?: no"
    end
  end

  describe "when log_dir_path does not exist" do
    test "outputs exists: false" do
      appsignal_config %{log_path: "/foo/bar/baz.log"}
      output = run()

      assert String.contains? output, "log_dir_path: /foo/bar\n    - Exists?: no"
      assert String.contains? output, "log_file_path: /foo/bar/baz.log\n    - Exists?: no"
    end
  end

  describe "when log_dir_path is not writable" do
    setup do
      log_dir_path = Path.expand("tmp/not_writable_path", File.cwd!)
      log_file_path = Path.expand("appsignal.log", log_dir_path)
      on_exit :clean_up, fn ->
        File.chmod!(log_dir_path, 0o755)
        File.rm_rf!(log_dir_path)
      end

      File.mkdir_p!(log_dir_path)
      File.touch!(log_file_path)
      File.chmod!(log_dir_path, 0o400)
      appsignal_config %{log_path: log_file_path}

      {:ok, %{log_dir_path: log_dir_path, log_file_path: log_file_path}}
    end

    test "outputs writable: false", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      output = run()

      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: no"
      # Can't read inside the directory so it's assumed to not exist
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Exists?: no"
    end
  end

  describe "when path is not owned by current user" do
    setup do
      log_dir_path = Path.expand("tmp/not_owned_path", File.cwd!)
      log_file_path = Path.expand("appsignal.log", log_dir_path)
      on_exit :clean_up, fn ->
        File.rm_rf!(log_dir_path)
      end

      File.mkdir_p!(log_dir_path)
      File.touch!(log_file_path)
      appsignal_config %{log_path: log_file_path}

      {:ok, %{log_dir_path: log_dir_path, log_file_path: log_file_path}}
    end

    test "outputs ownership uid", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      %{uid: uid} = File.stat!(log_dir_path)
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes\n    - Ownership?: (file: #{uid})"
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Writable?: yes\n    - Ownership?: (file: #{uid})"
    end
  end

  defp appsignal_config do
    Application.get_env(:appsignal, :config, %{})
  end

  defp appsignal_config(config) do
    Application.put_env(:appsignal, :config, Map.merge(appsignal_config(), config))
  end
end
