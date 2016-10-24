defmodule Appsignal.Phoenix.Channel do
  @moduledoc """
  Instrumentation for channel events

  Currently only incoming channel requests can be instrumented,
  e.g. in the `handle_in` function of your application. Add the
  `channel_action` function there, passing in a name for the channel
  action, the socket and the actual code that you are executing in the
  channel handler:

  ```
  defmodule SomeApp.MyChannel do

  use Appsignal.Phoenix.Channel

  def handle_in("ping" = action, _payload, socket) do
  channel_action(action, socket, fn ->
  # do some heave processing here...
  reply = perform_work()
  {:reply, {:ok, reply}, socket}
  end)
  end

  end
  ```

  Channel events will be displayed under the "Background jobs" tab,
  showing the channel module and the action argument that you entered.

  """

  alias Appsignal.Transaction

  @doc """
  Record a channel action. Meant to be called from the 'channel_action' instrumentation decorator.
  """
  def channel_action(module, name, %Phoenix.Socket{} = socket, function) do
    alias Appsignal.Transaction

    transaction = Transaction.start(Transaction.generate_id(), :background_job)

    action_str = "#{module}##{name}"
    <<"Elixir.", action :: binary>> = action_str
    Transaction.set_action(transaction, action)

    result = function.()

    resp = Transaction.finish(transaction)
    if resp == :sample do
      Appsignal.Phoenix.Channel.set_metadata(transaction, socket)
    end
    :ok = Transaction.complete(transaction)

    result
  end


  @doc """
  Given the `Appsignal.Transaction` and a `Phoenix.Socket`, add the
  socket metadata to the transaction.
  """
  def set_metadata(transaction, socket) do
    transaction
    |> Transaction.set_sample_data("params", socket.assigns |> Appsignal.Utils.ParamsFilter.filter_values)
    |> Transaction.set_sample_data("environment", request_environment(socket))
  end

  @socket_fields ~w(id channel endpoint handler ref topic transport)a
  defp request_environment(socket) do
    @socket_fields
    |> Enum.map(fn(k) -> {k, Map.get(socket, k)} end)
    |> Enum.into(%{})
  end

end
