defmodule Appsignal.LoggerTest do
  import AppsignalTest.Utils, only: [with_config: 2]
  use ExUnit.Case

  setup do
    start_supervised!(Appsignal.Test.Logger)
    :ok
  end

  test "logs when log level is debug or trace" do
    assert :ok ==
             with_config(
               %{log_level: "debug"},
               fn ->
                 Appsignal.Logger.debug("debug!")
               end
             )

    assert {:ok, [{"debug!"}]} == Appsignal.Test.Logger.get(:debug)
  end

  test "logs when log level is not debug or trace" do
    assert :ok ==
             with_config(
               %{log_level: "warn"},
               fn ->
                 Appsignal.Logger.debug("debug!")
               end
             )

    assert :error == Appsignal.Test.Logger.get(:debug)
  end
end
