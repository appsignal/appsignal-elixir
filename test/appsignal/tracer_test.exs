defmodule Appsignal.TracerTest do
  use ExUnit.Case

  describe "create_span/1" do
    test "returns a span" do
      assert %Appsignal.Span{} = Appsignal.Tracer.create_span("root")
    end
  end
end
