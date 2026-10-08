defmodule Appsignal.Plug.MetadataTest do
  use ExUnit.Case

  setup do
    %{conn: %Plug.Conn{}}
  end

  test "extracts the conn's host", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("host") == "www.example.com"
  end

  test "extracts the conn's method", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("method") == "GET"
  end

  test "extracts the conn's request_path", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("request_path") == ""
  end

  test "extracts the conn's port", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("port") == 0
  end

  test "extracts the conn's status", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("status") == nil
  end

  test "extracts the conn's request_id", %{conn: conn} do
    assert conn
           |> Appsignal.Metadata.metadata()
           |> Map.get("request_id") == nil
  end

  describe "when the conn's status is set" do
    setup %{conn: conn} do
      %{conn: %{conn | status: 200}}
    end

    test "extracts the conn's status", %{conn: conn} do
      assert conn
             |> Appsignal.Metadata.metadata()
             |> Map.get("status") == 200
    end
  end

  describe "when the conn's request_id is set" do
    setup %{conn: conn} do
      %{conn: Plug.Conn.put_resp_header(conn, "x-request-id", "request_id")}
    end

    test "extracts the conn's request_id", %{conn: conn} do
      assert conn
             |> Appsignal.Metadata.metadata()
             |> Map.get("request_id") == "request_id"
    end
  end

  describe "when the conn's request_headers are set" do
    setup %{conn: conn} do
      %{
        conn:
          conn
          |> Plug.Conn.put_req_header("accept", "text/html")
          |> Plug.Conn.put_req_header("foo", "bar")
      }
    end

    test "extracts the conn's request headers", %{conn: conn} do
      assert conn
             |> Appsignal.Metadata.metadata()
             |> Map.get("req_headers.accept") == "text/html"
    end

    test "does not extract request headers that are not listed in the request header configuration",
         %{conn: conn} do
      refute conn
             |> Appsignal.Metadata.metadata()
             |> Map.get("req_headers.foo")
    end
  end

  describe "when the conn's request_headers are nil" do
    setup %{conn: conn} do
      %{conn: %{conn | req_headers: nil}}
    end

    test "does not crash", %{conn: conn} do
      assert Appsignal.Metadata.metadata(conn)
    end
  end

  test "does not extract the conn's name if unset", %{conn: conn} do
    assert Appsignal.Metadata.name(conn) == nil
  end

  describe "when an appsignal_name is set" do
    setup %{conn: conn} do
      %{conn: Plug.Conn.put_private(conn, :appsignal_name, "appsignal_name")}
    end

    test "extracts the conn's name", %{conn: conn} do
      assert Appsignal.Metadata.name(conn) == "appsignal_name"
    end
  end

  describe "when phoenix_controller and phoenix_action are set" do
    setup %{conn: conn} do
      %{
        conn:
          conn
          |> Plug.Conn.put_private(:phoenix_controller, "TestController")
          |> Plug.Conn.put_private(:phoenix_action, "index")
      }
    end

    test "extracts the conn's name", %{conn: conn} do
      assert Appsignal.Metadata.name(conn) == "TestController#index"
    end
  end

  describe "when method and plug_route are set" do
    setup %{conn: conn} do
      %{
        conn:
          conn
          |> Map.put(:method, "GET")
          |> Plug.Conn.put_private(:plug_route, {"/", nil})
      }
    end

    test "extracts the conn's name", %{conn: conn} do
      assert Appsignal.Metadata.name(conn) == "GET /"
    end
  end

  test "extracts the conn's category", %{conn: conn} do
    assert Appsignal.Metadata.category(conn) == "call.plug"
  end

  describe "with a phoenix_endpoint" do
    setup %{conn: conn} do
      %{conn: Plug.Conn.put_private(conn, :phoenix_endpoint, Endpoint)}
    end

    test "extracts the conn's category", %{conn: conn} do
      assert Appsignal.Metadata.category(conn) == "call.phoenix"
    end
  end

  test "extracts the conn's params", %{conn: conn} do
    assert Appsignal.Metadata.params(conn) == %{}
  end

  test "extracts the conn's session data", %{conn: conn} do
    assert Appsignal.Metadata.session(conn) == %{}
  end
end
