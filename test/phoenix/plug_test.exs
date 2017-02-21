defmodule Appsignal.Phoenix.PlugTest do
  use ExUnit.Case
  use Plug.Test

  test "does what it needs to do" do
    # Create a test connection
    conn = conn(:get, "/test/123")

    # Invoke the plug
    conn = Appsignal.Phoenix.Plug.call(conn, %{})

    conn = conn
    |> Plug.Conn.resp(200, "ok")
    |> Plug.Conn.send_resp

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "ok"
  end
end
