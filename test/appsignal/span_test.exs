defmodule AppsignalSpanTest do
  use ExUnit.Case
  alias Appsignal.{Span, Tracer, WrappedNif}

  setup do
    WrappedNif.start_link()
    [span: Tracer.create_span("")]
  end

  describe ".trace_id/1" do
    test "returns an ok-tuple with the trace_id as a list", %{span: span} do
      {:ok, trace_id} = Span.trace_id(span)
      assert is_list(trace_id)
    end
  end

  describe ".span_id/1" do
    test "returns an ok-tuple with the span_id as a list", %{span: span} do
      {:ok, span_id} = Span.span_id(span)
      assert is_list(span_id)
    end
  end

  describe ".set_name/2" do
    test "returns the span", %{span: span} do
      assert Span.set_name(span, "test") == span
    end
  end

  describe ".set_namespace/2" do
    test "returns the span", %{span: span} do
      assert Span.set_namespace(span, "test") == span
    end
  end

  describe ".set_error/3" do
    test "returns the span", %{span: span} do
      try do
        raise "Exception!"
      catch
        :error, error ->
          assert Span.add_error(span, error, System.stacktrace()) == span
      end
    end
  end

  describe ".set_sample_data/3" do
    test "returns the span", %{span: span} do
      assert Span.set_sample_data(span, "key", %{param: "value"}) == span
    end
  end
end
