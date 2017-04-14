defmodule Mix.Tasks.Appsignal.DiagnoseTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Mock
  import AppsignalTest.Utils

  @system Application.get_env(:appsignal, :appsignal_system, Appsignal.System)
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  defp run do
    capture_io(fn -> Mix.Tasks.Appsignal.Diagnose.run(nil) end)
  end

  setup do
    @system.start_link
    @nif.start_link
    # By default use the same as the actual state of the Nif
    @nif.set(:loaded?, Appsignal.Nif.loaded?)

    # By default, Push API key is valid
    bypass = Bypass.open
    setup_with_config(%{
      endpoint: "http://localhost:#{bypass.port}"
    })

    Bypass.expect bypass, fn conn ->
      assert "/1/auth" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "")
    end

    unless Code.ensure_loaded?(Appsignal.Agent) do
      {_, _} = Code.eval_file("agent.ex")
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

    agent_version = Appsignal.Agent.version
    assert agent_version
    assert String.contains? output, "Agent version: #{agent_version}"
  end

  @tag :skip_env_test_no_nif
  describe "when Nif is loaded" do
    test_with_mock "outputs that the Nif is loaded", Appsignal.Nif, [:passthrough], [loaded?: fn -> true end] do
      output = run()
      assert String.contains? output, "Nif loaded: yes"
    end
  end

  describe "when Nif is not loaded" do
    setup do: @nif.set(:loaded?, false)

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
    refute String.contains? output, "Heroku:"
  end

  describe "when on Heroku" do
    setup do: @system.set(:heroku, true)

    test "outputs Heroku: yes" do
      output = run()
      assert String.contains? output, "Heroku: yes"
    end
  end

  describe "when running in a container" do
    setup do: @nif.set(:running_in_container?, true)

    test "outputs Container: yes" do
      output = run()
      assert String.contains? output, "Container: yes"
    end
  end

  describe "when not running in a container" do
    setup do: @nif.set(:running_in_container?, false)

    test "outputs Container: no" do
      output = run()
      assert String.contains? output, "Container: no"
    end
  end

  describe "when not root user" do
    test "outputs root user: no" do
      output = run()
      assert String.contains? output, "root user: no"
    end
  end

  describe "when root user" do
    setup do: @system.set(:root, true)

    test "outputs warning about running as root" do
      output = run()
      assert String.contains? output, "root user: yes (not recommended)"
    end
  end

  @tag :skip_env_test_no_nif
  test "runs agent in diagnose mode" do
    output = run()
    assert String.contains? output, "Agent diagnostics"
    assert String.contains? output, "Running agent in diagnose mode"
    assert String.contains? output, "Valid config present"
    assert String.contains? output, "Logger initialized successfully"
    assert String.contains? output, "Lock path is writable"
    assert String.contains? output, "Agent diagnose finished"
  end

  @tag :skip_env_test_no_nif
  describe "when config is not active" do
    test "runs agent in diagnose mode, but doesn't change the active state" do
      @nif.set(:run_diagnose, true)

      output = with_config(%{active: false}, &run/0)
      assert String.contains? output, "active: false"
      assert String.contains? output, "Agent diagnostics"
      assert String.contains? output, "Running agent in diagnose mode"
      assert String.contains? output, "Valid config present"
      assert String.contains? output, "Logger initialized successfully"
      assert String.contains? output, "Lock path is writable"
      assert String.contains? output, "Agent diagnose finished"
    end
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
      setup_with_config(%{push_api_key: ""})

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
      output = with_config(%{log_path: nil}, &run/0)
      assert String.contains? output, "Paths"
      assert String.contains? output, "log_dir_path: /tmp"
      assert String.contains? output, "log_file_path: /tmp/appsignal.log"
    end
  end

  describe "when log_dir_path is writable" do
    setup do
      %{log_dir_path: log_dir_path, log_file_path: log_file_path} = prepare_tmp_dir "writable_path"

      {:ok, %{log_dir_path: log_dir_path, log_file_path: log_file_path}}
    end

    @tag :skip_env_test
    @tag :skip_env_test_phoenix
    test "outputs writable, but doesn't create log file", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes"
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Exists?: no"
    end

    @tag :skip_env_test_no_nif
    test "outputs writable and creates log file", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes"
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Writable?: yes"
    end
  end

  describe "when log_dir_path does not exist" do
    test "outputs exists: false" do
      output = with_config(%{log_path: "/foo/bar/baz.log"}, &run/0)

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
      setup_with_config(%{log_path: log_file_path})

      {:ok, %{log_dir_path: log_dir_path, log_file_path: log_file_path}}
    end

    test "outputs writable: false", %{log_dir_path: log_dir_path, log_file_path: log_file_path} do
      output = run()

      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: no"
      # Can't read inside the directory so it's assumed to not exist
      assert String.contains? output, "log_file_path: #{log_file_path}\n    - Exists?: no"
    end
  end

  describe "when path is owned by current user" do
    setup do
      %{log_dir_path: log_dir_path} = prepare_tmp_dir "not_owned_path"

      {:ok, %{log_dir_path: log_dir_path}}
    end

    test "outputs ownership uid", %{log_dir_path: log_dir_path} do
      %{uid: uid} = File.stat!(log_dir_path)
      @system.set(:uid, uid)
      output = run()
      assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes\n    - Ownership?: yes (file: #{uid}, process: #{@system.uid})"
    end
  end

  describe "when path is not owned by current user" do
    setup do
      %{log_dir_path: log_dir_path} = prepare_tmp_dir "owned_path"

      {:ok, %{log_dir_path: log_dir_path}}
    end

    test "outputs ownership uid", %{log_dir_path: log_dir_path} do
        %{uid: uid} = File.stat!(log_dir_path)
        output = run()
        assert String.contains? output, "log_dir_path: #{log_dir_path}\n    - Writable?: yes\n    - Ownership?: no (file: #{uid}, process: #{@system.uid})"
      end
  end

  defp prepare_tmp_dir(path) do
    log_dir_path = Path.expand("tmp/#{path}", File.cwd!)
    log_file_path = Path.expand("appsignal.log", log_dir_path)
    on_exit :clean_up, fn ->
      File.rm_rf!(log_dir_path)
    end

    File.mkdir_p!(log_dir_path)
    setup_with_config(%{log_path: log_file_path})

    %{log_dir_path: log_dir_path, log_file_path: log_file_path}
  end

end
