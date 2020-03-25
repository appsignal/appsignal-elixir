defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  doctest Appsignal.Phoenix
  import Phoenix.ConnTest
  alias Appsignal.{Test, Tracer}
  @endpoint PhoenixWeb.Endpoint

  setup do
    PhoenixWeb.Endpoint.start_link([])
    Test.Span.start_link()
    %{span: Tracer.create_span("root")}
  end

  describe "GET /" do
    setup do
      %{conn: get(build_conn(), "/")}
    end

    test "sends the response", %{conn: conn} do
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    end
  end

  describe "GET /exception" do
    setup do
      try do
        %{conn: get(build_conn(), "/exception")}
      catch
        :error, reason -> %{reason: reason}
      end
    end

    test "reraises the error", %{reason: reason} do
      assert %RuntimeError{} = reason
    end

    test "adds an error to the current span", %{span: span, reason: reason} do
      assert [{^span, ^reason, _}] = Test.Span.get!(:add_error)
    end
  end
end
