defmodule Appsignal.DemoTest do
  use ExUnit.Case
  alias Appsignal.{Demo, Span, Test}

  setup do
    Test.Nif.start_link()
    Test.Tracer.start_link()
    Test.Span.start_link()
    :ok
  end

  describe "send_performance_sample/0" do
    setup do
      Demo.send_performance_sample()
    end

    test "creates a root span and four child spans" do
      assert {:ok,
              [
                {"http_request", %Span{}},
                {"http_request", %Span{}},
                {"http_request", %Span{}},
                {"http_request", %Span{}},
                {"http_request"}
              ]} = Test.Tracer.get(:create_span)
    end

    test "sets the spans' names" do
      assert {:ok,
              [
                {%Span{}, "render.phoenix_template"},
                {%Span{}, "query.ecto"},
                {%Span{}, "query.ecto"},
                {%Span{}, "call.phoenix_endpoint"},
                {%Span{}, "DemoController#hello"}
              ]} = Test.Span.get(:set_name)
    end

    test "sets the 'demo_sample' attribute" do
      assert {:ok, [{%Span{}, "demo_sample", true}]} = Test.Span.get(:set_attribute)
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "method" => "GET",
        "request_path" => "/"
      })
    end

    test "closes all spans" do
      assert {:ok, [{%Span{}}, {%Span{}}, {%Span{}}, {%Span{}}, {%Span{}}]} =
               Test.Tracer.get(:close_span)
    end
  end

  describe "send_error_sample/0" do
    setup do
      Demo.send_error_sample()
    end

    test "creates a root span" do
      assert {:ok, [{"http_request"}]} = Test.Tracer.get(:create_span)
    end

    test "sets the spans' names" do
      assert {:ok, [{%Span{}, "DemoController#hello"}]} = Test.Span.get(:set_name)
    end

    test "sets the 'demo_sample' attribute" do
      assert {:ok, [{%Span{}, "demo_sample", true}]} = Test.Span.get(:set_attribute)
    end

    test "adds the error to the span" do
      assert {:ok, [{%Span{}, :error, %TestError{}, _}]} = Test.Span.get(:add_error)
    end

    test "sets the span's sample data" do
      assert_sample_data("environment", %{
        "method" => "GET",
        "request_path" => "/"
      })
    end

    test "closes all spans" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp assert_sample_data(asserted_key, asserted_data) do
    {:ok, sample_data} = Test.Span.get(:set_sample_data)

    assert Enum.any?(sample_data, fn {%Span{}, key, data} ->
             key == asserted_key and data == asserted_data
           end)
  end
end
