defmodule AppsignalSpanTest do
  use ExUnit.Case
  alias Appsignal.Span

  setup do
    [span: Span.create()]
  end

  describe ".create/0" do
    test "creates a new span", %{
      span: %Span{reference: reference, span_id: span_id, trace_id: trace_id}
    } do
      assert is_reference(reference)
      assert is_list(span_id)
      assert is_list(trace_id)
    end
  end

  describe ".create/1" do
    setup do
      [span: Span.create("test")]
    end

    test "creates a new span", %{
      span: %Span{reference: reference, span_id: span_id, trace_id: trace_id}
    } do
      assert is_reference(reference)
      assert is_list(span_id)
      assert is_list(trace_id)
    end
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
