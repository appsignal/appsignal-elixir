defmodule Appsignal.FinchTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  test "attaches to Finch events automatically" do
    assert attached?([:finch, :request, :start])
    assert attached?([:finch, :request, :stop])
  end

  describe "finch_request_start/4, without a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      :telemetry.execute(
        [:finch, :request, :start],
        %{},
        %{
          name: FinchTest,
          request: %{
            method: "GET",
            scheme: :https,
            path: "/",
            query: "",
            host: "example.com",
            port: 443
          }
        }
      )
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "finch_request_start/4, and finch_request_stop/4 with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:finch, :request, :start],
        %{},
        %{
          name: FinchTest,
          request: %{
            method: "GET",
            scheme: :https,
            path: "/",
            query: nil,
            host: "example.com",
            port: 443
          }
        }
      )

      :telemetry.execute(
        [:finch, :request, :stop],
        %{},
        %{}
      )
    end

    test "creates a span with a parent" do
      assert {:ok, [{"http_request", %Span{}}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET https://example.com/"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute("appsignal:category", "request.finch")
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp attribute(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Finch, event}
    end)
  end
end
