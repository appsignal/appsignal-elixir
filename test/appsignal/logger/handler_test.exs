defmodule Appsignal.Logger.HandlerTest do
  use ExUnit.Case
  require Logger

  setup do
    Appsignal.Logger.Handler.add("some_group")
    start_supervised!(Appsignal.Test.Nif)
    on_exit(fn -> Appsignal.Logger.Handler.remove() end)
    :ok
  end

  case Version.compare(System.version(), "1.15.0") do
    :lt ->
      nil

    _ ->
      test "add/2 sets up a :logger handler" do
        Logger.error("A bad thing happened!")

        assert [
                 {"some_group", 6, 3, "A bad thing happened!", _}
               ] = Appsignal.Test.Nif.get!(:log)
      end

      test "remove/0 removes the :logger handler" do
        :logger.remove_handler(:appsignal_log)

        Logger.error("A bad thing happened!")

        assert :error = Appsignal.Test.Nif.get(:log)
      end
  end
end
