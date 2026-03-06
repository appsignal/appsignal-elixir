defmodule Appsignal.HTTPoisonTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  describe "request/5, without a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      result = Appsignal.HTTPoison.request(:get, "https://example.com/path")

      {:ok, result: result}
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end

    test "returns the underlying response", %{result: result} do
      assert result == {:ok, :fake_response}
    end
  end

  describe "request/5, with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")
      result = Appsignal.HTTPoison.request(:get, "https://example.com/path?foo=bar")

      {:ok, result: result}
    end

    test "creates a span with a parent" do
      assert {:ok, [{"http_request", %Span{}}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET https://example.com"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "request.httpoison")
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end

    test "returns the underlying response", %{result: result} do
      assert result == {:ok, :fake_response}
    end
  end

  describe "request/5, when the request raises" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)
      start_supervised!(FakeHTTPoisonBase)

      Appsignal.Tracer.create_span("http_request")
      FakeHTTPoisonBase.set_raise(true)

      try do
        Appsignal.HTTPoison.request(:get, "https://example.com/path")
      rescue
        RuntimeError -> :ok
      end

      :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp attribute?(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end
end
