defmodule Appsignal.LoggerTest do
  import AppsignalTest.Utils, only: [with_config: 2]
  use ExUnit.Case

  setup do
    start_supervised!(Appsignal.Test.Logger)
    :ok
  end

  test "logs when debug mode is turned on" do
    with_config(
      %{debug: true},
      fn ->
        Appsignal.Logger.debug("debug!")
      end
    )

    assert {:ok, [{"debug!"}]} == Appsignal.Test.Logger.get(:debug)
  end

  test "logs when debug mode is turned off" do
    with_config(
      %{debug: false},
      fn ->
        Appsignal.Logger.debug("debug!")
      end
    )

    assert :error == Appsignal.Test.Logger.get(:debug)
  end
end
