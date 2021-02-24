defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  doctest Appsignal.Phoenix
  import Phoenix.ConnTest
  alias Appsignal.{Span, Test}
  @endpoint PhoenixWeb.Endpoint

  setup do
    start_supervised!(PhoenixWeb.Endpoint)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)

    :ok
  end

  describe "GET /" do
    setup do
      get("/")
    end

    test "sends the response", %{conn: conn} do
      assert html_response(conn, 200) =~ "Welcome to Phoenix!"
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "PhoenixWeb.Controller#index"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /exception" do
    setup do
      get("/exception")
    end

    test "reraises the error", %{reason: reason} do
      assert %RuntimeError{} = reason
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "PhoenixWeb.Controller#exception"}]} = Test.Span.get(:set_name)
    end

    test "adds an error to the span", %{reason: reason} do
      assert {:ok, [{%Span{}, :error, ^reason, _}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /exception, when disabled" do
    setup :disable_appsignal

    setup do
      get("/exception")
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "adds the name to a nil-span" do
      assert {:ok, [{nil, "PhoenixWeb.Controller#exception"}]} = Test.Span.get(:set_name)
    end

    test "adds the error to a nil-span", %{reason: reason} do
      assert {:ok, [{nil, :error, ^reason, _}]} = Test.Span.get(:add_error)
    end

    test "closes the nil-span" do
      assert {:ok, [{nil}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "GET /404" do
    setup do
      get("/404")
    end

    test "reraises the error", %{reason: reason} do
      assert %Phoenix.Router.NoRouteError{} = reason
    end

    test "creates a root span" do
      assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert :error = Test.Span.get(:set_name)
    end

    test "adds an error to the span", %{reason: reason} do
      assert :error = Test.Span.get(:add_error)
    end

    test "does not close the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp get(path) do
    %{conn: get(build_conn(), path)}
  rescue
    reason -> %{reason: reason}
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end
end
