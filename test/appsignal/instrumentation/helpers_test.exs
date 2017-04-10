defmodule AppsignalHelpersTest do
  use ExUnit.Case

  import Mock

  alias Appsignal.{Transaction, Instrumentation.Helpers}

  test_with_mock "instrument with transaction", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("foo", :http_request)
    call_instrument(t)
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "name", "title", "", 0)
  end

  test_with_mock "instrument with pid", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("bar", :http_request)
    call_instrument(self())
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "name", "title", "", 0)
  end

  test "instrument with nil" do
    call_instrument(nil)
  end

  defp call_instrument(arg) do
    r = Helpers.instrument(arg, "name", "title", fn() ->
      # some slow function
      :timer.sleep(100)
      :result
    end)
    assert :result == r
  end
end
