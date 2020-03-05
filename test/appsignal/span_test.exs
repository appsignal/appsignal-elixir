defmodule AppsignalSpanTest do
  use ExUnit.Case
  alias Appsignal.{Span, WrappedNif}

  setup do
    WrappedNif.start_link()
    :ok
  end

  describe ".create_root/2" do
    setup :create_root_span

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"root"}] = WrappedNif.get(:create_root_span)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span} do
      assert span.pid == self()
    end
  end

  describe ".create_root/2, when passing a pid" do
    setup :create_root_span_in_other_process

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"root"}] = WrappedNif.get(:create_root_span)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span, pid: pid} do
      assert span.pid == pid
    end
  end

  describe ".create_child/3" do
    setup [:create_root_span, :create_child_span]

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a child span through the Nif", %{parent: parent} do
      assert [{"child", parent_trace_id, parent_span_id}] = WrappedNif.get(:create_child_span)

      assert {:ok, ^parent_trace_id} = Span.trace_id(parent)
      assert {:ok, ^parent_span_id} = Span.span_id(parent)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span} do
      assert span.pid == self()
    end
  end

  describe ".create_child/3, with a nil-parent" do
    setup do
      [span: Span.create_child("orphan", nil, self())]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"orphan"}] = WrappedNif.get(:create_root_span)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span} do
      assert span.pid == self()
    end
  end

  describe ".create_child/3, when passing a pid" do
    setup [:create_root_span, :create_child_span_in_other_process]

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a child span through the Nif", %{parent: parent} do
      assert [{"child", parent_trace_id, parent_span_id}] = WrappedNif.get(:create_child_span)

      assert {:ok, ^parent_trace_id} = Span.trace_id(parent)
      assert {:ok, ^parent_span_id} = Span.span_id(parent)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span, pid: pid} do
      assert span.pid == pid
    end
  end

  describe ".trace_id/1" do
    setup :create_root_span

    test "returns an ok-tuple with the trace_id as a list", %{span: span} do
      {:ok, trace_id} = Span.trace_id(span)
      assert is_list(trace_id)
    end
  end

  describe ".span_id/1" do
    setup :create_root_span

    test "returns an ok-tuple with the span_id as a list", %{span: span} do
      {:ok, span_id} = Span.span_id(span)
      assert is_list(span_id)
    end
  end

  describe ".set_name/2" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_name(span, "test") == span
    end
  end

  describe ".set_namespace/2" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_namespace(span, "test") == span
    end
  end

  describe ".set_error/3" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          raise "Exception!"
        catch
          :error, error ->
            Span.add_error(span, error, System.stacktrace())
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end
  end

  describe ".set_sample_data/3" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_sample_data(span, "key", %{param: "value"}) == span
    end
  end

  describe ".close/1, when passing a nil" do
    test "returns nil" do
      assert Span.close(nil) == nil
    end
  end

  describe ".close/1, when passing a span" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.close(span) == span
    end

    test ".closes the span through the Nif", %{span: %Span{reference: reference} = span} do
      Span.close(span)
      assert [{^reference}] = WrappedNif.get(:close_span)
    end
  end

  describe ".to_map/1" do
    setup :create_root_span

    test "returns a map with span metadata", %{span: span} do
      assert %{
               "name" => "root",
               "namespace" => ""
             } = Span.to_map(span)
    end
  end

  defp create_root_span(_context) do
    [span: Span.create_root("root", self())]
  end

  defp create_child_span(%{span: span}) do
    [span: Span.create_child("child", span, self()), parent: span]
  end

  defp create_root_span_in_other_process(_context) do
    pid = Process.whereis(WrappedNif)
    [span: Span.create_root("root", pid), pid: pid]
  end

  defp create_child_span_in_other_process(%{span: span}) do
    pid = Process.whereis(WrappedNif)
    [span: Span.create_child("child", span, pid), pid: pid, parent: span]
  end
end
