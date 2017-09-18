defmodule UsingAppsignalPhoenixChannel do
  import Appsignal.Phoenix.Channel, only: [channel_action: 5]
  use Appsignal.Instrumentation.Decorators

  @decorate channel_action()
  def handle_in("decorated", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @decorate channel_action()
  def handle_in("decorated_with_unbound_payload", _, socket) do
    {:reply, :ok, socket}
  end

  def handle_in("instrumented" = action, payload, socket) do
    channel_action(__MODULE__, action, socket, payload, fn ->
      {:reply, {:ok, payload}, socket}
    end)
  end
end

defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    Appsignal.FakeTransaction.start_link

    [
      socket: %Phoenix.Socket{
        channel: Elixir.PhoenixChatExampleWeb.RoomChannel,
        endpoint: Elixir.PhoenixChatExampleWeb.Endpoint,
        handler: Elixir.PhoenixChatExampleWeb.UserSocket,
        ref: 2,
        topic: "room:lobby",
        transport: Elixir.Phoenix.Transports.WebSocket,
        id: 1
      }
    ]
  end

  test "instruments a channel action with a decorator", %{socket: socket} do
    UsingAppsignalPhoenixChannel.handle_in("decorated", %{"body" => "Hello, world!"}, socket)

    assert [{"123", :channel}] == FakeTransaction.started_transactions
    assert "UsingAppsignalPhoenixChannel#decorated" == FakeTransaction.action
    assert %{
      "environment" => %{
        channel: PhoenixChatExampleWeb.RoomChannel,
        endpoint: PhoenixChatExampleWeb.Endpoint,
        handler: PhoenixChatExampleWeb.UserSocket,
        id: 1,
        ref: 2,
        topic: "room:lobby",
        transport: Phoenix.Transports.WebSocket
      },
      "params" => %{}
    } == FakeTransaction.sample_data
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.finished_transactions
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.completed_transactions
  end

  test "instruments a channel action with an instrumentation helper", %{socket: socket} do
    UsingAppsignalPhoenixChannel.handle_in("instrumented", %{"body" => "Hello, world!"}, socket)

    assert [{"123", :channel}] == FakeTransaction.started_transactions
    assert "UsingAppsignalPhoenixChannel#instrumented" == FakeTransaction.action
    assert %{
      "environment" => %{
        channel: PhoenixChatExampleWeb.RoomChannel,
        endpoint: PhoenixChatExampleWeb.Endpoint,
        handler: PhoenixChatExampleWeb.UserSocket,
        id: 1,
        ref: 2,
        topic: "room:lobby",
        transport: Phoenix.Transports.WebSocket
      },
      "params" => %{"body" => "Hello, world!"}
    } == FakeTransaction.sample_data
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.finished_transactions
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.completed_transactions
  end

  test "filters parameters", %{socket: socket} do
    AppsignalTest.Utils.with_config(%{filter_parameters: ["password"]}, fn() ->
      UsingAppsignalPhoenixChannel.handle_in("instrumented", %{"password" => "secret"}, socket)
      assert "[FILTERED]" == FakeTransaction.sample_data["params"]["password"]
    end)
  end
end
