defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
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
      PlugWithAppsignal.call(conn(:get, "/"), [])

      :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "GET /"}] = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get(:close_span)
    end
  end
end
