defmodule AppsignalHelpersTest do
  use ExUnit.Case
  use Plug.Test

  import Mock

  alias Appsignal.{Transaction, Helpers}

  test_with_mock "instrument", Appsignal.Transaction, [:passthrough], [] do

    t = Transaction.start("foo", :http_request)
    call_instrument(t)
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "name", "title", "", 0)
  end

  test_with_mock "instrument %Plug.Conn{}", Appsignal.Transaction, [:passthrough], [] do

    conn = conn(:get, "/test/123")

    # Invoke the plug
    conn = Appsignal.Plug.call(conn, %{})
    call_instrument(conn)
    t = conn.assigns.appsignal_transaction
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "name", "title", "", 0)
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
