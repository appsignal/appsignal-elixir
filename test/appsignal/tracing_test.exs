defmodule AppsignalTracingTest do
  use ExUnit.Case
  alias Appsignal.{Span, Span.Registry, Span.Dictionary}

  test "creates and closes a span with attributes" do
    span =
      %Span{reference: reference} =
      "name"
      |> Span.create()
      |> Span.set_attribute("string", "AppsignalTracingTest#action")
      |> Span.set_attribute("integer", 42)
      |> Span.set_attribute("true", true)
      |> Span.set_attribute("false", false)
      |> Span.set_attribute("float", 3.2)

    assert is_reference(reference)

    assert Registry.lookup() == span
    assert Dictionary.lookup() == span

    Span.close()

    refute Process.get(:appsignal_span)
    assert Registry.lookup() == nil
  end

  test "creates and closes a span with a child span in the same process" do
    span = %Span{trace_id: trace_id} = Span.create("name")
    assert Registry.lookup() == span
    assert Dictionary.lookup() == span

    child_span = %Span{trace_id: ^trace_id} = Span.create("child")
    assert Registry.lookup() == child_span
    assert Dictionary.lookup() == child_span

    Span.close()

    assert Registry.lookup() == span
    assert Dictionary.lookup() == span

    Span.close()

    refute Registry.lookup()
    refute Dictionary.lookup()
  end

  test "creates and closes a span with a child span in a separate process" do
    Span.create("name")

    %Span{trace_id: parent_trace_id} = Registry.lookup()

    Task.async(fn ->
      Span.create("child")

      %Span{trace_id: trace_id, span_id: span_id} = span = Registry.lookup(self())

      assert trace_id == parent_trace_id
      assert is_list(span_id)
      assert Dictionary.lookup() == span

      Span.close()

      refute Dictionary.lookup()
      refute Registry.lookup()
    end)
    |> Task.await()

    Span.close()
  end
end
