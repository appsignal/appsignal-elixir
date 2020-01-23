defmodule Appsignal.TracerTest do
  use ExUnit.Case
  alias Appsignal.{Span, Tracer}

  describe "create_span/1" do
    setup do
      [span: Tracer.create_span("root")]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "registers the span", %{span: span} do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), span}]
    end
  end

  describe "current_span/1, when no span exists" do
    test "returns nil" do
      assert Tracer.current_span() == nil
    end
  end
end
