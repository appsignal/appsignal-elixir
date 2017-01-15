defmodule Appsignal.ReleaseUpgradeTest do
  use ExUnit.Case

  use Appsignal.Config

  test "config_change/3" do

    Appsignal.Config.initialize()
    assert false == config[:skip_session_data]

    # when doing a release upgrade, all runtime-set envirnoment variables get reset
    Application.delete_env(:appsignal, :config)

    # config is not initialized
    assert nil == config[:skip_session_data]

    Appsignal.config_change([], [], [])

    assert false == config[:skip_session_data]

  end

end
