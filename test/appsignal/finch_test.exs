defmodule Appsignal.FinchTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}
  import AppsignalTest.Utils, only: [with_config: 2]

  test "attaches to Finch events automatically" do
    assert attached?([:finch, :request, :start])
    assert attached?([:finch, :request, :stop])
    assert attached?([:finch, :request, :exception])
  end

  test "does not attach to Finch events when :instrument_finch is set to false" do
    :telemetry.detach({Appsignal.Finch, [:finch, :request, :start]})
    :telemetry.detach({Appsignal.Finch, [:finch, :request, :stop]})
    :telemetry.detach({Appsignal.Finch, [:finch, :request, :exception]})

    with_config(%{instrument_finch: false}, fn -> Appsignal.start([], []) end)

    assert !attached?([:finch, :request, :start])
    assert !attached?([:finch, :request, :stop])
    assert !attached?([:finch, :request, :exception])

    [:ok, :ok, :ok] = Appsignal.Finch.attach()
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
            query: "foo=bar",
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

  describe "finch_request_start/4, with an unsupported event shape" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      :telemetry.execute(
        [:finch, :request, :start],
        %{},
        # Finch 0.11 will emit events such as this, where the properties
        # of the request are not contained in a `request` map.
        %{
          method: "GET",
          scheme: :https,
          path: "/",
          host: "example.com",
          port: 443
        }
      )
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end

    test "does not detach the handler" do
      assert attached?([:finch, :request, :start])
    end
  end

  describe "finch_request_stop/4, with an unsupported event shape" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      :telemetry.execute(
        [:finch, :request, :stop],
        %{},
        # Finch 0.11 will emit events such as this, where the properties
        # of the request are not contained in a `request` map.
        %{
          method: "GET",
          scheme: :https,
          path: "/",
          host: "example.com",
          port: 443
        }
      )
    end

    test "does not close a span" do
      assert Test.Tracer.get(:close_span) == :error
    end

    test "does not detach the handler" do
      assert attached?([:finch, :request, :stop])
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
            query: "foo=bar",
            host: "example.com",
            port: 443
          }
        }
      )

      :telemetry.execute(
        [:finch, :request, :stop],
        %{},
        %{name: "", request: %{}}
      )
    end

    test "creates a span with a parent" do
      assert {:ok, [{"http_request", %Span{}}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET https://example.com"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "request.finch")
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "finch_request_exception/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute(
        [:finch, :request, :exception],
        %{},
        %{name: "", request: %{}}
      )
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

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Finch, event}
    end)
  end
end
