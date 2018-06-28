defmodule Appsignal.ReleaseUpgradeTest do
  use ExUnit.Case, async: true
  use Appsignal.Config
  alias Appsignal.Nif
  import AppsignalTest.Utils

  @tag :skip_env_test_no_nif
  test "config_change/3" do
    assert Nif.env_get("_APPSIGNAL_APP_NAME") == ''

    with_config(valid_configuration(), fn ->
      # First start
      # Basically the contents of `Appsignal.initialize`
      Appsignal.initialize()

      # Sets config to Application environment
      assert config()[:name] == "AppSignal test suite app v1"
      # Sets config to system environment variables
      assert Nif.env_get("_APPSIGNAL_APP_NAME") == 'AppSignal test suite app v1'

      # The system reloads the application config (set in Mix) during the upgrade.
      new_config =
        valid_configuration()
        |> Map.put(:name, "AppSignal test suite app v2")

      with_config(new_config, fn ->
        # Hot reload / upgrade
        config_reload_pid = Appsignal.config_change([], [], [])
        # The config is reloaded in a separate process so we wait for it here
        assert Process.alive?(config_reload_pid)

        Process.monitor(config_reload_pid)

        assert_receive({:DOWN, _, :process, ^config_reload_pid, _}, 5000)

        assert config()[:name] == "AppSignal test suite app v2"
        assert Nif.env_get("_APPSIGNAL_APP_NAME") == 'AppSignal test suite app v2'
      end)
    end)
  end

  def valid_configuration do
    %{
      active: true,
      debug: false,
      enable_host_metrics: true,
      endpoint: "https://push.appsignal.com",
      env: :dev,
      filter_parameters: [],
      ignore_actions: [],
      ignore_errors: [],
      log: "file",
      name: "AppSignal test suite app v1",
      push_api_key: "00000000-0000-0000-0000-000000000000",
      send_params: true,
      skip_session_data: false,
      valid: false
    }
  end
end
