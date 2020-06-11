defmodule InstrumentedModule do
  use Appsignal.Instrumentation.Decorators

  @decorate instrument()
  def call do
    :ok
  end
end

defmodule Appsignal.InstrumentationTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  describe "instrument/2" do
    setup do
      Test.Nif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

      %{return: InstrumentedModule.call()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.call/0"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end
end
