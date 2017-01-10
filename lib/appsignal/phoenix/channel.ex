if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.Channel do
    @moduledoc """
    Instrumentation for channel events

    ## Instrumenting a channel's `handle_in/3`

    Currently, incoming channel requests can be instrumented, by adding
    code to the `handle_in` function of your application. We use
    [function decorators](https://github.com/arjan/decorator) to
    minimize the amount of code you have to add to your channel.

        defmodule SomeApp.MyChannel do
          use Appsignal.Instrumentation.Decorators

          @decorate channel_action
          def handle_in("ping", _payload, socket) do
            # your code here..
          end
        end

    Channel events will be displayed under the "Background jobs" tab,
    showing the channel module and the action argument that you entered.

    ## Instrumenting without decorators

    You can also decide not to use function decorators. In that case,
    use the `channel_action/3` function directly, passing in a name for
    the channel action, the socket and the actual code that you are
    executing in the channel handler:

        defmodule SomeApp.MyChannel do
          import Appsignal.Phoenix.Channel, only: [channel_action: 4]

          def handle_in("ping" = action, _payload, socket) do
            channel_action(__MODULE__, action, socket, fn ->
              # do some heave processing here...
              reply = perform_work()
              {:reply, {:ok, reply}, socket}
            end)
          end
        end

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
end
