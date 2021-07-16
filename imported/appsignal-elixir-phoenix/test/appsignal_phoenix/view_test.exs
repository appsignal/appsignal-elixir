defmodule Appsignal.ViewTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)

    :ok
  end

  describe "when calling render/2 without a parent span" do
    setup do
      %{return: PhoenixWeb.View.render("index.html", %{})}
    end

    test "does not create a root span" do
      assert :error = Test.Tracer.get(:create_span)
    end

    test "renders the template", %{return: return} do
      assert {:safe, ["<h1>Welcome to ", "Phoenix", "!</h1>\n"]} = return
    end
  end

  describe "when a root span exist, calling render/2 with a binary first argument" do
    setup do
      %{
        parent: Appsignal.Tracer.create_span("http_request"),
        return: PhoenixWeb.View.render("index.html", %{})
      }
    end

    test "creates a child span", %{parent: parent} do
      assert {:ok, [{_, ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Render test/support/index.html"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "render.phoenix_template")
    end

    test "sets the span's title attribute" do
      assert attribute("title", "test/support/index.html")
    end

    test "renders the template", %{return: return} do
      assert {:safe, ["<h1>Welcome to ", "Phoenix", "!</h1>\n"]} = return
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "when a root span exists, calling render/2 with a non-binary first argument" do
    setup do
      %{
        parent: Appsignal.Tracer.create_span("http_request"),
        return: PhoenixWeb.View.render("index.html", %{})
      }
    end

    test "creates a child span", %{parent: parent} do
      assert {:ok, [{_, ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "Render test/support/index.html"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "render.phoenix_template")
    end

    test "sets the span's title attribute" do
      assert attribute("title", "test/support/index.html")
    end

    test "renders the template", %{return: return} do
      assert {:safe, ["<h1>Welcome to ", "Phoenix", "!</h1>\n"]} = return
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp attribute(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end
end
