defmodule Mix.Tasks.Appsignal.InstallTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import AppsignalTest.Utils

  @demo Application.get_env(:appsignal, :appsignal_demo, Appsignal.Demo)

  setup do
    @demo.start_link

    bypass = Bypass.open
    setup_with_env(%{
      "APPSIGNAL_PUSH_API_ENDPOINT" => "http://localhost:#{bypass.port}"
    })

    {:ok, %{bypass: bypass}}
  end

  describe "without push api key" do
    defp run_without_push_api_key do
      capture_io(fn -> Mix.Tasks.Appsignal.Install.run([]) end)
    end

    test "outputs AppSignal support header" do
      output = run_without_push_api_key()
      assert String.contains? output, "AppSignal install"
      assert String.contains? output, "https://appsignal.com"
      assert String.contains? output, "http://docs.appsignal.com"
      assert String.contains? output, "support@appsignal.com"
      assert String.contains? output, "Welcome to AppSignal!"
    end

    test "outputs a missing push api key error" do
      output = run_without_push_api_key()
      assert String.contains? output, "We're missing an AppSignal Push API key and cannot continue."
      assert String.contains? output, "mix appsignal.install push_api_key"
    end
  end

  describe "with invalid push api key" do
    setup %{bypass: bypass} do
      Bypass.expect bypass, fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 401, "")
      end

      {:ok, %{bypass: bypass}}
    end

    defp run_with_invalid_push_api_key do
      capture_io(fn ->
        assert catch_exit(Mix.Tasks.Appsignal.Install.run(["foobar"])) == :shutdown
      end)
    end

    test "outputs AppSignal support header" do
      output = run_with_invalid_push_api_key()
      assert String.contains? output, "AppSignal install"
      assert String.contains? output, "https://appsignal.com"
      assert String.contains? output, "http://docs.appsignal.com"
      assert String.contains? output, "support@appsignal.com"
      assert String.contains? output, "Welcome to AppSignal!"
    end

    test "outputs an invalid push api key error" do
      output = run_with_invalid_push_api_key()
      assert String.contains? output, "Validating Push API key: Invalid"
    end
  end

  describe "with valid push api key" do
    @test_directory "tmp/install_project"
    @test_config_directory Path.join(@test_directory, "config")

    setup context do
      Bypass.expect context[:bypass], fn conn ->
        assert "/1/auth" == conn.request_path
        assert "GET" == conn.method
        Plug.Conn.resp(conn, 200, "")
      end

      if context[:file_config] do
        File.mkdir_p!(@test_config_directory)
        create_config_file()
        create_config_file_for_env("dev")
        create_config_file_for_env("stag")
        create_config_file_for_env("prod")

        on_exit :cleanup_tmp_dir, fn ->
          File.rm_rf!(@test_directory)
        end
      end

      :ok
    end

    defp run_with_file_config do
      run_with_file_config_in(@test_directory)
    end
    defp run_with_file_config_in(directory) do
      capture_io([input: "AppSignal test suite app\n1"], fn ->
        File.cd!(directory, fn ->
          Mix.Tasks.Appsignal.Install.run(["my_push_api_key"])
        end)
      end)
    end

    defp run_with_environment_config do
      capture_io([input: "AppSignal test suite app\n2"], fn ->
        Mix.Tasks.Appsignal.Install.run(["my_push_api_key"])
      end)
    end

    test "outputs AppSignal support header" do
      output = run_with_environment_config()
      assert String.contains? output, "AppSignal install"
      assert String.contains? output, "https://appsignal.com"
      assert String.contains? output, "http://docs.appsignal.com"
      assert String.contains? output, "support@appsignal.com"
      assert String.contains? output, "Welcome to AppSignal!"
    end

    test "outputs a valid push api key message" do
      output = run_with_environment_config()
      assert String.contains? output, "Validating Push API key: Valid"
    end

    test "requires an application name" do
      # First entry is empty and thus invalid, so it asks for the name again.
      output = capture_io([input: "\nAppSignal test suite app\n2"], fn ->
        Mix.Tasks.Appsignal.Install.run(["my_push_api_key"])
      end)

      assert String.contains? output, "What is your application's name?: " <>
        "I'm sorry, I didn't quite get that.\nWhat is your application's name?: "
    end

    test "requires a configuration method" do
      # First entry is empty and thus invalid, so it asks for the option again.
      # Second time the option doesn't exist, so it asks for the option again.
      output = capture_io([input: "foo\n\n3\n2"], fn ->
        Mix.Tasks.Appsignal.Install.run(["my_push_api_key"])
      end)

      assert String.contains? output,
        "What is your preferred configuration method? (1/2): I'm sorry, I didn't quite get that.\n" <>
        "What is your preferred configuration method? (1/2): I'm sorry, I didn't quite get that."
      assert String.contains? output, "Configuring with environment variables."
    end

    test "with environment variable config outputs environment variables" do
      output = run_with_environment_config()
      assert String.contains? output, "What is your preferred configuration method? (1/2): "
      assert String.contains? output, "Configuring with environment variables."
      assert String.contains? output, ~s(APPSIGNAL_APP_NAME="AppSignal test suite app")
      assert String.contains? output, ~s(APPSIGNAL_APP_ENV="production")
      assert String.contains? output, ~s(APPSIGNAL_PUSH_API_KEY="my_push_api_key")
    end

    @tag :file_config
    test "file based config option writes to env-based config files" do
      output = run_with_file_config()
      assert String.contains? output, "What is your preferred configuration method? (1/2): "
      assert String.contains? output, "Writing config file config/appsignal.exs: Success!\n"
      assert String.contains? output, "Linking config to config/config.exs: Success!\n"

      # Create AppSignal config file
      assert File.exists?(Path.join(@test_config_directory, "appsignal.exs"))
      # Test the contents of AppSignal config file
      appsignal_config = File.read!(Path.join(@test_config_directory, "appsignal.exs"))
      assert String.contains? appsignal_config, ~s(use Mix.Config\n\n) <>
        ~s(config :appsignal, :config,\n) <>
        ~s(  name: "AppSignal test suite app",\n) <>
        ~s(  push_api_key: "my_push_api_key",\n) <>
        ~s(  env: Mix.env\n)

      # Imports AppSignal config in config.exs file
      app_config = File.read!(Path.join(@test_config_directory, "config.exs"))
      assert String.contains? app_config, ~s(\nimport_config "appsignal.exs")

      # Activates AppSignal in the production, staging and development environments
      assert String.contains? output, "Activating dev environment: Success!"
      assert String.contains? output, "Activating stag environment: Success!"
      assert String.contains? output, "Activating prod environment: Success!"
      assert config_active_for_env?("dev")
      assert config_active_for_env?("stag")
      assert config_active_for_env?("prod")
    end

    @tag :file_config
    test "file based config option writes to a single config file" do
      directory = "tmp/install_project_single_config_file"
      config_directory = Path.join(directory, "config")
      File.mkdir_p!(config_directory)
      create_config_file_in(config_directory)

      output = run_with_file_config_in(directory)
      assert String.contains? output, "What is your preferred configuration method? (1/2): "
      assert String.contains? output, "Writing config file config/appsignal.exs: Success!\n"
      assert String.contains? output, "Linking config to config/config.exs: Success!\n"

      # Create AppSignal config file
      assert File.exists?(Path.join(config_directory, "appsignal.exs"))
      # Test the contents of AppSignal config file
      appsignal_config = File.read!(Path.join(config_directory, "appsignal.exs"))
      assert String.contains? appsignal_config, ~s(use Mix.Config\n\n) <>
        ~s(config :appsignal, :config,\n) <>
        ~s(  active: true,\n) <>
        ~s(  name: "AppSignal test suite app",\n) <>
        ~s(  push_api_key: "my_push_api_key",\n) <>
        ~s(  env: Mix.env\n)

      # Imports AppSignal config in config.exs file
      app_config = File.read!(Path.join(config_directory, "config.exs"))
      assert String.contains? app_config, ~s(\nimport_config "appsignal.exs")
    end

    @tag :file_config
    test "file based config option doesn't crash if a config file doesn't exist" do
      File.rm(Path.join(@test_config_directory, "stag.exs"))
      output = run_with_file_config()

      assert String.contains? output, "Activating dev environment: Success!"
      refute String.contains? output, "Activating stag environment:"
      assert String.contains? output, "Activating prod environment: Success!"
      assert config_active_for_env?("dev")
      refute config_active_for_env?("stag")
      assert config_active_for_env?("prod")
    end

    @tag :file_config
    test "file based config option doesn't crash if the config file is already linked" do
      File.open!(Path.join(@test_config_directory, "config.exs"), [:write])
      |> IO.binwrite(~s(use Mix.Config\n# config\nimport_config "appsignal.exs"))
      |> File.close
      File.open!(Path.join(@test_config_directory, "dev.exs"), [:append])
      |> IO.binwrite(~s(\nconfig :appsignal, :config, active: true\n))
      |> File.close

      output = run_with_file_config()
      assert String.contains? output, "Linking config to config/config.exs: Success! (Already linked?)"
      assert String.contains? output, "Activating dev environment: Success! (Already active?)"
    end

    test "outputs 'installed!' message" do
      output = run_with_environment_config()
      assert String.contains? output, "AppSignal installed!"
    end

    @tag :skip_env_test_phoenix
    test "without Phoenix it prints no link to Phoenix integration documentation" do
      output = run_with_environment_config()
      refute String.contains? output, "AppSignal detected a Phoenix app"
      refute String.contains? output, "http://docs.appsignal.com/elixir/integrations/phoenix.html"
    end

    @tag :skip_env_test_no_nif
    @tag :skip_env_test
    test "with Phoenix it prints link to Phoenix integration documentation" do
      output = run_with_environment_config()
      assert String.contains? output, "AppSignal detected a Phoenix app"
      assert String.contains? output, "http://docs.appsignal.com/elixir/integrations/phoenix.html"
    end

    test "sends a demo sample to AppSignal" do
      output = run_with_environment_config()
      assert @demo.get(:create_transaction_error_request)
      assert @demo.get(:create_transaction_performance_request)
      assert String.contains? output, "Demonstration sample data sent!"
    end
  end

  defp create_config_file, do: create_config_file_for_env("config")

  defp create_config_file_in(directory) do
    create_config_file_for_env_in("config", directory)
  end

  defp create_config_file_for_env(env) do
    create_config_file_for_env_in(env, @test_config_directory)
  end

  defp create_config_file_for_env_in(env, directory) do
    File.open!(Path.join(directory, "#{env}.exs"), [:write])
    |> IO.binwrite("use Mix.Config\n# #{env}")
    |> File.close
  end

  # Checks if the original file content is present and if the env has AppSignal
  # activation config.
  defp config_active_for_env?(env) do
    case File.read(Path.join(@test_config_directory, "#{env}.exs")) do
      {:ok, env_config} ->
        String.contains?(env_config, ~s(use Mix.Config\n# #{env}\n)) &&
          String.contains?(env_config, ~s(\nconfig :appsignal, :config, active: true))
      {:error, _} -> false
    end
  end
end
