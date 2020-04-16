defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()

    socket = %Phoenix.Socket{
      channel: PhoenixWeb.RoomChannel,
      endpoint: PhoenixWeb.Endpoint,
      handler: PhoenixWeb.UserSocket,
      ref: 2,
      topic: "room:lobby",
      transport: Elixir.Phoenix.Transports.WebSocket,
      id: 1
    }

    %{return: PhoenixWeb.Channel.handle_in("new_msg", %{"body" => "Hello world!"}, socket)}
  end

  test "calls the passed function, and returns its return", %{return: return} do
    assert {:noreply, %Phoenix.Socket{}} = return
  end

  test "creates a root span" do
    assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
  end

  test "sets the span's name" do
    assert {:ok, [{%Span{}, "PhoenixWeb.Channel#new_msg"}]} = Test.Span.get(:set_name)
  end

  test "sets the span's parameters" do
    assert_sample_data("params", %{"body" => "Hello world!"})
  end

  test "sets the span's sample data" do
    assert_sample_data("environment", %{
      "channel" => PhoenixWeb.RoomChannel,
      "endpoint" => PhoenixWeb.Endpoint,
      "handler" => PhoenixWeb.UserSocket,
      "id" => 1,
      "ref" => 2,
      "topic" => "room:lobby",
      "transport" => Phoenix.Transports.WebSocket
    })
  end

  test "closes the span" do
    assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
  end

  defp assert_sample_data(asserted_key, asserted_data) do
    {:ok, sample_data} = Test.Span.get(:set_sample_data)

    assert Enum.any?(sample_data, fn {%Span{}, key, data} ->
             key == asserted_key and data == asserted_data
           end)
  end
end
