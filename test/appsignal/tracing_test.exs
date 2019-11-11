defmodule AppsignalTracingTest do
  use ExUnit.Case

  test "creates and closes a span with attributes" do
    span =
      %Appsignal.Span{reference: reference} =
      "name"
      |> Appsignal.Span.create()
      |> Appsignal.Span.set_attribute("string", "AppsignalTracingTest#action")
      |> Appsignal.Span.set_attribute("integer", 42)
      |> Appsignal.Span.set_attribute("true", true)
      |> Appsignal.Span.set_attribute("false", false)
      |> Appsignal.Span.set_attribute("float", 3.2)

    assert is_reference(reference)

    assert Appsignal.Span.Registry.lookup() == span
    assert Process.get(:appsignal_span) == span

    Appsignal.Span.close()

    refute Process.get(:appsignal_span)
    assert Appsignal.Span.Registry.lookup() == nil
  end

  test "creates and closes a span with a child span" do
    Appsignal.Span.create("name")

    %Appsignal.Span{trace_id: parent_trace_id} = Appsignal.Span.Registry.lookup()

    Task.async(fn ->
      Appsignal.Span.create("child")

      %Appsignal.Span{trace_id: trace_id, span_id: span_id} =
        span = Appsignal.Span.Registry.lookup(self())

      assert trace_id == parent_trace_id
      assert is_list(span_id)
      assert Process.get(:appsignal_span) == span

      Appsignal.Span.close()

      refute Process.get(:appsignal_span)
      assert Appsignal.Span.Registry.lookup() == nil
    end)
    |> Task.await()

    Appsignal.Span.close()
  end
end
