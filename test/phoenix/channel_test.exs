defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  import Mock

  alias Phoenix.Socket
  alias Appsignal.Transaction

  defmodule SomeApp.MyChannel do

    use Appsignal.Instrumentation.Decorators

    @decorate channel_action
    def handle_in("ping", payload, socket) do
      {:reply, {:ok, payload}, socket}
    end

    import Appsignal.Phoenix.Channel, only: [channel_action: 4]

    def handle_in("pong" = action, payload, socket) do
      channel_action(__MODULE__, action, socket, fn ->
        {:reply, {:ok, payload}, socket}
      end)
    end

  end

  test_with_mock "channel_action function decorator", Appsignal.Transaction, [:passthrough], [] do
    SomeApp.MyChannel.handle_in("ping", :payload, %Socket{})
    t = Appsignal.TransactionRegistry.lookup(self())
    assert called Transaction.start(t.id, :channel)
    assert called Transaction.set_action(t, "Appsignal.Phoenix.ChannelTest.SomeApp.MyChannel#ping")
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end

  test_with_mock "direct calling of channel_action function", Appsignal.Transaction, [:passthrough], [] do
    SomeApp.MyChannel.handle_in("pong", :payload, %Socket{})
    t = Appsignal.TransactionRegistry.lookup(self())
    assert called Transaction.start(t.id, :channel)
    assert called Transaction.set_action(t, "Appsignal.Phoenix.ChannelTest.SomeApp.MyChannel#pong")
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end

end
