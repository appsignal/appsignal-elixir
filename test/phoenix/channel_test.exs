defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case, async: true
  import Mock

  alias Phoenix.Socket
  alias Appsignal.Transaction

  defmodule SomeApp.MyChannel do

    use Appsignal.Instrumentation.Decorators

    @decorate channel_action
    def handle_in("ping", payload, socket) do
      {:reply, {:ok, payload}, socket}
    end

  end


  test_with_mock "channel function instrumentation", Appsignal.Transaction, [:passthrough], [] do

    SomeApp.MyChannel.handle_in("ping", :payload, %Socket{})

    t = Appsignal.TransactionRegistry.lookup(self())

    assert called Transaction.start(t.id, :background_job)
    assert called Transaction.set_action(t, "Appsignal.Phoenix.ChannelTest.SomeApp.MyChannel#ping")
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)

  end

end
