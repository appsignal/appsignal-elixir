defmodule AppsignalSpanTest do
  use ExUnit.Case
  alias Appsignal.Span

  setup do
    [span: Span.create("test")]
  end

  describe ".trace_id/1" do
    test "returns a span's trace_id", %{span: %Span{reference: reference, trace_id: trace_id}} do
      assert {:ok, ^trace_id} = Span.trace_id(reference)
    end
  end

  describe ".span_id/1" do
    test "returns a span's span_id", %{span: %Span{reference: reference, span_id: span_id}} do
      assert {:ok, ^span_id} = Span.span_id(reference)
    end
  end
end
