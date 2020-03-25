defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  doctest Appsignal.Phoenix
  import Phoenix.ConnTest
  alias Appsignal.{Span, Test, Tracer}
  @endpoint PhoenixWeb.Endpoint

  setup do
    PhoenixWeb.Endpoint.start_link([])
    Test.Tracer.start_link()
    Test.Span.start_link()

    :ok
  end

  describe "GET /" do
    setup do
      %{conn: get(build_conn(), "/")}
    end

    test "sends the response", %{conn: conn} do
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    end

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "PhoenixWeb.Controller#index"}] = Test.Span.get!(:set_name)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
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

    test "creates a root span" do
      assert Test.Tracer.get!(:create_span) == [{"unknown"}]
    end

    test "sets the span's name" do
      assert [{%Span{}, "PhoenixWeb.Controller#exception"}] = Test.Span.get!(:set_name)
    end

    test "adds an error to the span", %{reason: reason} do
      assert [{%Span{}, ^reason, _}] = Test.Span.get!(:add_error)
    end

    test "closes the span" do
      assert [{%Span{}}] = Test.Tracer.get!(:close_span)
    end
  end
end
