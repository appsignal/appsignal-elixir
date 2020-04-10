defmodule Appsignal.Phoenix.Template.EExEngineTest do
  use ExUnit.Case
  alias Appsignal.{Phoenix.Template.EExEngine, Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()

    return =
      "test/support/index.html.eex"
      |> EExEngine.compile("name")
      |> Code.eval_quoted()

    %{return: return}
  end

  test "creates a root span" do
    assert Test.Tracer.get(:create_span) == {:ok, [{"web", nil}]}
  end

  test "sets the span's name" do
    assert {:ok, [{%Span{}, "render.phoenix_template"}]} = Test.Span.get(:set_name)
  end

  test "sets the span's title attribute" do
    assert {:ok, [{%Span{}, "title", "test/support/index.html.eex"}]} =
             Test.Span.get(:set_attribute)
  end

  test "renders the template", %{return: return} do
    assert {"<h1>Welcome to Phoenix!</h1>\n", _} = return
  end

  test "closes the span" do
    assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
  end
end
