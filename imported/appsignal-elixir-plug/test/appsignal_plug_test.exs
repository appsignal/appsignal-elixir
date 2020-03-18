defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/exception" do
    raise "Exception!"

    send_resp(conn, 200, "Exception!")
  end
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  use Plug.Test
  alias Appsignal.{Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()
    :ok
  end

  describe "GET /" do
    setup do
      get("/")

      :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "GET /"}] = Test.Span.get!(:set_name)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
    end
  end

  describe "GET /exception" do
    setup do
      get("/exception")
    end

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "GET /exception"}] = Test.Span.get!(:set_name)
    end

    test "adds the error to the span", %{exception: exception, stacktrace: stack} do
      assert [{%Span{}, ^exception, ^stack}] = Test.Span.get!(:add_error)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
    end
  end

  defp get(path) do
    try do
      [conn: PlugWithAppsignal.call(conn(:get, path), [])]
    rescue
      wrapper_error in Plug.Conn.WrapperError ->
        [
          conn: wrapper_error.conn,
          exception: wrapper_error.reason,
          stacktrace: System.stacktrace()
        ]
    end
  end
end
