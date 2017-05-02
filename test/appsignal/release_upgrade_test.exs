defmodule Appsignal.ReleaseUpgradeTest do
  use ExUnit.Case
  use Appsignal.Config

  import AppsignalTest.Utils

  test "config_change/3" do
    assert System.get_env("_APPSIGNAL_APP_NAME") == nil

    with_config(valid_configuration(), fn() ->
      # First start
      # Basically the contents of `Appsignal.initialize`
      Appsignal.initialize

      # Sets config to Application environment
      assert config()[:name] == "AppSignal test suite app v1"
      # Sets config to system environment variables
      assert System.get_env("_APPSIGNAL_APP_NAME") == "AppSignal test suite app v1"

      # The system reloads the application config (set in Mix) during the upgrade.
      new_config = valid_configuration()
      |> Map.put(:name, "AppSignal test suite app v2")

      with_config(new_config, fn() ->
        # Hot reload / upgrade
        config_reload_pid = Appsignal.config_change([], [], [])
        # The config is reloaded in a separate process so we wait for it here
        assert Process.alive?(config_reload_pid)
        :timer.sleep 3500
        refute Process.alive?(config_reload_pid)

        assert config()[:name] == "AppSignal test suite app v2"
        assert System.get_env("_APPSIGNAL_APP_NAME") == "AppSignal test suite app v2"
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
      filter_parameters: nil,
      hostname: "Alices-MBP.example.com",
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
