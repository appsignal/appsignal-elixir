defmodule Appsignal.ViewTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()

    %{return: PhoenixWeb.View.render("index.html", %{})}
  end

  test "creates a root span" do
    assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
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

  defp attribute(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end
end
