defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils
  import ExUnit.CaptureIO
  alias Appsignal.{Error.Backend, Span, Test, WrappedNif}

  setup do
    WrappedNif.start_link()
    Test.Tracer.start_link()
    Test.Span.start_link()

    :ok
  end

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Logger.add_backend(Backend)
  end

  describe "when an exception is raised" do
    setup do
      [pid: spawn(fn -> raise "Exception" end)]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"", nil, ^pid}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{}, %RuntimeError{message: "Exception"}, stack}]} =
                 Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
      end)
    end
  end
end
