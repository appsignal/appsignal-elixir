defmodule Appsignal.Phoenix.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Mock


  test "does what it needs to do" do
    # Create a test connection
    conn = conn(:get, "/test/123")

    # Invoke the plug
    conn = Appsignal.Phoenix.Plug.call(conn, %{})

    assert conn.assigns.appsignal_transaction != nil

    conn = conn
    |> Plug.Conn.resp(200, "ok")
    |> Plug.Conn.send_resp

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "ok"

  end

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  test_with_mock "send session data", Appsignal.Transaction, [:passthrough], [] do

    Application.put_env(:appsignal, :config, [skip_session_data: false])

    conn = get_session_conn()
    t = conn.assigns.appsignal_transaction
    Appsignal.Transaction.set_request_metadata(t, conn)

    assert called Appsignal.Transaction.set_sample_data(t, "session_data", conn.private.plug_session)
  end

  test_with_mock "do not send session data", Appsignal.Transaction, [:passthrough], [] do

    Application.put_env(:appsignal, :config, [skip_session_data: true])

    conn = get_session_conn()
    t = conn.assigns.appsignal_transaction
    Appsignal.Transaction.set_request_metadata(t, conn)

    assert not called Appsignal.Transaction.set_sample_data(t, "session_data", conn.private.plug_session)
  end



  defp get_session_conn() do
    conn = conn(:get, "/")
    |> sign_conn()
    |> put_session("foo", "bar")
    |> Appsignal.Phoenix.Plug.call(%{})
    |> Plug.Conn.resp(200, "ok")
    |> Plug.Conn.send_resp
  end


  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  defp sign_conn(conn, secret \\ @secret) do
    put_in(conn.secret_key_base, secret)
    |> Plug.Session.call(@signing_opts)
    |> fetch_session
  end

end
