defmodule AppsignalTracingTest do
  use ExUnit.Case

  test "creates and closes a span with attributes and a child span" do
    reference =
      "name"
      |> Appsignal.Span.create()
      |> Appsignal.Span.set_attribute("string", "AppsignalTracingTest#action")
      |> Appsignal.Span.set_attribute("integer", 42)
      |> Appsignal.Span.set_attribute("true", true)
      |> Appsignal.Span.set_attribute("false", false)
      |> Appsignal.Span.set_attribute("float", 3.2)

    {:ok, trace_id} = Appsignal.Span.trace_id(reference)
    {:ok, span_id} = Appsignal.Span.span_id(reference)

    child =
      Appsignal.Span.create(
        List.to_string(trace_id),
        List.to_string(span_id),
        "name"
      )

    Appsignal.Span.close(child)

    Appsignal.Span.close(reference)
  end
end
