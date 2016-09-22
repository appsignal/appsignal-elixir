defmodule AppsignalConfigTest do
  @moduledoc """
  Test the configuratoin
  """

  use ExUnit.Case

  alias Appsignal.Config

  test "unconfigured" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "")
    Application.delete_env(:appsignal, :config)
    assert {:error, :invalid_config} = Config.initialize()
  end

  test "minimum config from OS env" do
    System.put_env("APPSIGNAL_PUSH_API_KEY", "-test-")
    assert :ok = Config.initialize()
  end

  test "minimum config from application env" do
    Application.put_env(:appsignal, :config,
      push_api_key: "-test")
    assert :ok = Config.initialize()
  end

  test "app revision" do
    System.put_env("APP_REVISION", "123")
    assert "123" = init_config()[:revision]
  end

  test "app revision from application env" do
    Application.put_env(:appsignal, :config,
      push_api_key: "-test",
      revision: "123")
    assert "123" = init_config()[:revision]
  end

  test "app revision from application env gets put in system env" do
    Application.put_env(:appsignal, :config,
      push_api_key: "-test",
      revision: "123")
    init_config()
    assert "123" = System.get_env("APP_REVISION")
  end

  defp init_config do
    Config.initialize()
    Application.get_all_env(:appsignal)[:config]
  end

end
