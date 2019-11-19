defmodule DecoratedPhoenixChannel do
  import Appsignal.Phoenix.Channel, only: [channel_action: 5]
  use Appsignal.Instrumentation.Decorators

  @decorate channel_action()
  def handle_in("decorated", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
end

defmodule InstrumentedPhoenixChannel do
  import Appsignal.Phoenix.Channel, only: [channel_action: 5]
  use Appsignal.Instrumentation.Decorators

  def handle_in("instrumented" = action, payload, socket) do
    channel_action(__MODULE__, action, socket, payload, fn ->
      {:reply, {:ok, payload}, socket}
    end)
  end

  def handle_in("instrumented_with_exception" = action, payload, socket) do
    channel_action(__MODULE__, action, socket, payload, fn ->
      raise("Exception!")
    end)
  end
end

defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = Appsignal.FakeTransaction.start_link()

    [
      socket: %Phoenix.Socket{
        channel: Elixir.PhoenixChatExampleWeb.RoomChannel,
        endpoint: Elixir.PhoenixChatExampleWeb.Endpoint,
        handler: Elixir.PhoenixChatExampleWeb.UserSocket,
        ref: 2,
        topic: "room:lobby",
        transport: Elixir.Phoenix.Transports.WebSocket,
        id: 1
      },
      fake_transaction: fake_transaction
    ]
  end

  test "instruments a channel action with a decorator", %{
    socket: socket,
    fake_transaction: fake_transaction
  } do
    DecoratedPhoenixChannel.handle_in("decorated", %{"body" => "Hello, world!"}, socket)

    assert [{"123", :channel}] == FakeTransaction.started_transactions(fake_transaction)
    assert "DecoratedPhoenixChannel#decorated" == FakeTransaction.action(fake_transaction)

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
           } == FakeTransaction.sample_data(fake_transaction)

    assert [%Appsignal.Transaction{id: "123"}] =
             FakeTransaction.finished_transactions(fake_transaction)

    assert [%Appsignal.Transaction{id: "123"}] =
             FakeTransaction.completed_transactions(fake_transaction)
  end

  test "instruments a channel action with an instrumentation helper", %{
    socket: socket,
    fake_transaction: fake_transaction
  } do
    InstrumentedPhoenixChannel.handle_in("instrumented", %{"body" => "Hello, world!"}, socket)

    assert [{"123", :channel}] == FakeTransaction.started_transactions(fake_transaction)
    assert "InstrumentedPhoenixChannel#instrumented" == FakeTransaction.action(fake_transaction)

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
           } == FakeTransaction.sample_data(fake_transaction)

    assert [%Appsignal.Transaction{id: "123"}] =
             FakeTransaction.finished_transactions(fake_transaction)

    assert [%Appsignal.Transaction{id: "123"}] =
             FakeTransaction.completed_transactions(fake_transaction)
  end

  describe "for a channel action with an exception" do
    setup %{socket: socket} do
      :ok =
        try do
          InstrumentedPhoenixChannel.handle_in(
            "instrumented_with_exception",
            %{"body" => "Hello, world!"},
            socket
          )
        catch
          :error, %RuntimeError{message: "Exception!"} -> :ok
          type, reason -> {type, reason}
        end
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "sets the channel's action name", %{fake_transaction: fake_transaction} do
      assert "InstrumentedPhoenixChannel#instrumented_with_exception" ==
               FakeTransaction.action(fake_transaction)
    end

    test "sets sample data", %{fake_transaction: fake_transaction} do
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
             } == FakeTransaction.sample_data(fake_transaction)
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions(fake_transaction)
    end

    test "sets the transaction error", %{fake_transaction: fake_transaction} do
      assert [
               {
                 %Appsignal.Transaction{},
                 "RuntimeError",
                 "Exception!",
                 _stack
               }
             ] = FakeTransaction.errors(fake_transaction)
    end

    test "ignores the process' pid" do
      AppsignalTest.Utils.until(fn ->
        assert Appsignal.TransactionRegistry.lookup(self()) == :ignored
      end)
    end
  end

  test "filters parameters", %{socket: socket, fake_transaction: fake_transaction} do
    AppsignalTest.Utils.with_config(%{filter_parameters: ["password"]}, fn ->
      InstrumentedPhoenixChannel.handle_in("instrumented", %{"password" => "secret"}, socket)
      assert "[FILTERED]" == FakeTransaction.sample_data(fake_transaction)["params"]["password"]
    end)
  end

  describe "when AppSignal is disabled" do
    test "does not start a transaction", %{
      socket: socket,
      fake_transaction: fake_transaction
    } do
      AppsignalTest.Utils.with_config(%{active: false}, fn ->
        InstrumentedPhoenixChannel.handle_in("instrumented", %{"body" => "Hello, world!"}, socket)
      end)

      refute FakeTransaction.started_transaction?(fake_transaction)
    end
  end
end
