defmodule AppsignalTracingTest do
  use ExUnit.Case

  test "creates and closes a span with attributes" do
    reference =
      "name"
      |> Appsignal.Span.create()
      |> Appsignal.Span.set_attribute("string", "AppsignalTracingTest#action")
      |> Appsignal.Span.set_attribute("integer", 42)
      |> Appsignal.Span.set_attribute("true", true)
      |> Appsignal.Span.set_attribute("false", false)
      |> Appsignal.Span.set_attribute("float", 3.2)

    [{pid, trace_id, span_id}] = Appsignal.Span.Registry.lookup()
    assert self() == pid
    assert is_list(trace_id)
    assert is_list(span_id)
    assert Process.get(:appsignal_trace_id) == trace_id
    assert Process.get(:appsignal_span_id) == span_id

    Appsignal.Span.close(reference)
  end

  test "creates and closes a span with a child span" do
    reference = Appsignal.Span.create("name")

    [{_pid, parent_trace_id, _parent_span_id}] = Appsignal.Span.Registry.lookup()

    Task.async(fn ->
      child = Appsignal.Span.create("child")

      [{pid, trace_id, span_id}] = Appsignal.Span.Registry.lookup(self())
      assert self() == pid
      assert trace_id == parent_trace_id
      assert is_list(span_id)

      Appsignal.Span.close(child)
    end)
    |> Task.await()

    Appsignal.Span.close(reference)
  end
end
