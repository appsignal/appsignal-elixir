defmodule UsingAppsignalPhoenixChannel do
  import Appsignal.Phoenix.Channel, only: [channel_action: 4]
  use Appsignal.Instrumentation.Decorators

  @decorate channel_action()
  def handle_in("decorated", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("instrumented" = action, payload, socket) do
    channel_action(__MODULE__, action, socket, fn ->
      {:reply, {:ok, payload}, socket}
    end)
  end
end

defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    Appsignal.FakeTransaction.start_link
    :ok
  end

  test "instruments a channel action with a decorator" do
    UsingAppsignalPhoenixChannel.handle_in("decorated", :payload, %Phoenix.Socket{})

    assert [{"123", :channel}] == FakeTransaction.started_transactions
    assert "UsingAppsignalPhoenixChannel#decorated" == FakeTransaction.action
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.finished_transactions
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.completed_transactions
  end

  test "instruments a channel action with an instrumentation helper" do
    UsingAppsignalPhoenixChannel.handle_in("instrumented", :payload, %Phoenix.Socket{})

    assert [{"123", :channel}] == FakeTransaction.started_transactions
    assert "UsingAppsignalPhoenixChannel#instrumented" == FakeTransaction.action
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.finished_transactions
    assert [%Appsignal.Transaction{id: "123"}] = FakeTransaction.completed_transactions
  end
end
