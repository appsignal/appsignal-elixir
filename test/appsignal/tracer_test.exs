defmodule Appsignal.TracerTest do
  use ExUnit.Case
  alias Appsignal.{Span, Tracer}

  describe "create_span/1" do
    test "returns a span" do
      assert %Span{} = Tracer.create_span("root")
    end
  end
end
