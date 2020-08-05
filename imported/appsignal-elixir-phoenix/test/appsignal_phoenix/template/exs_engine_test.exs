defmodule Appsignal.Phoenix.Template.ExsEngineTest do
  use ExUnit.Case
  alias Appsignal.{Phoenix.Template.ExsEngine, Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()

    return =
      "test/support/index.html.exs"
      |> ExsEngine.compile("name")
      |> Code.eval_quoted()

    %{return: return}
  end

  test "creates a root span" do
    assert {:ok, [{_, nil}]} = Test.Tracer.get(:create_span)
  end

  test "sets the span's name" do
    assert {:ok, [{%Span{}, "Render test/support/index.html.exs"}]} = Test.Span.get(:set_name)
  end

  test "sets the span's category" do
    assert attribute("appsignal:category", "render.phoenix_template")
  end

  test "sets the span's title attribute" do
    assert attribute("title", "test/support/index.html.exs")
  end

  test "renders the template", %{return: return} do
    assert {"<h1>Welcome to Phoenix!</h1>\n", _} = return
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
