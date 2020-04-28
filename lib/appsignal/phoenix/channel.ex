if Appsignal.phoenix?() do
  defmodule Appsignal.Phoenix.Channel do
    alias Appsignal.{ErrorHandler, Transaction, TransactionRegistry, Stacktrace, Utils.MapFilter}
    import Appsignal.Utils
    @transaction Application.get_env(:appsignal, :appsignal_transaction, Transaction)

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

    ### Adding channel payloads

    Channel payloads aren't included by default, but can be added by using
    `Appsignal.Transaction.set_sample_data/2` using the "params" key:

        defmodule SomeApp.MyChannel do
          use Appsignal.Instrumentation.Decorators

          @decorate channel_action
          def handle_in("ping", payload, socket) do
            Appsignal.Transaction.set_sample_data(
              "params", Appsignal.Utils.MapFilter.filter_parameters(payload)
            )

            # your code here..
          end
        end

    ## Instrumenting without decorators

    You can also decide not to use function decorators. In that case,
    use the `channel_action/4` function directly, passing in a name for
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

    ### Adding channel payloads

    To add channel payloads, use `channel_action/5`:

        defmodule SomeApp.MyChannel do
          import Appsignal.Phoenix.Channel, only: [channel_action: 5]

          def handle_in("ping" = action, payload, socket) do
            channel_action(__MODULE__, action, socket, payload, fn ->
              # do some heave processing here...
              reply = perform_work()
              {:reply, {:ok, reply}, socket}
            end)
          end
        end
    """

    @doc """
    Record a channel action. Meant to be called from the 'channel_action' instrumentation decorator.
    """
    @spec channel_action(atom | String.t(), String.t(), Phoenix.Socket.t(), fun) :: any
    def channel_action(module, name, %Phoenix.Socket{} = socket, function) do
      channel_action(module, name, %Phoenix.Socket{} = socket, %{}, function)
    end

    @spec channel_action(atom | String.t(), String.t(), Phoenix.Socket.t(), map, fun) :: any
    def channel_action(module, name, %Phoenix.Socket{} = socket, params, function) do
      transaction =
        @transaction.generate_id()
        |> @transaction.start(:channel)
        |> @transaction.set_action("#{module_name(module)}##{name}")

      try do
        function.()
      catch
        kind, reason ->
          stacktrace = Stacktrace.get()
          ErrorHandler.set_error(transaction, reason, stacktrace)
          finish_with_socket(transaction, socket, params)
          TransactionRegistry.ignore(self())
          :erlang.raise(kind, reason, stacktrace)
      else
        result ->
          finish_with_socket(transaction, socket, params)
          result
      end
    end

    @spec finish_with_socket(Transaction.t() | nil, Phoenix.Socket.t(), map()) :: :ok | nil
    defp finish_with_socket(transaction, socket, params) do
      if @transaction.finish(transaction) == :sample do
        transaction
        |> @transaction.set_sample_data("params", MapFilter.filter_parameters(params))
        |> @transaction.set_sample_data("environment", request_environment(socket))
      end

      @transaction.complete(transaction)
    end

    @doc """
    Given the `Appsignal.Transaction` and a `Phoenix.Socket`, add the
    socket metadata to the transaction.
    """
    @spec set_metadata(Transaction.t(), Phoenix.Socket.t()) :: Transaction.t()
    def set_metadata(transaction, socket) do
      IO.warn(
        "Appsignal.Channel.set_metadata/1 is deprecated. Set params and environment data directly with Appsignal.Transaction.set_sample_data/2 instead."
      )

      transaction
      |> @transaction.set_sample_data("params", MapFilter.filter_parameters(socket.assigns))
      |> @transaction.set_sample_data("environment", request_environment(socket))
    end

    @socket_fields ~w(id channel endpoint handler ref topic transport)a
    @spec request_environment(Phoenix.Socket.t()) :: map
    defp request_environment(socket) do
      @socket_fields
      |> Enum.into(%{}, fn k -> {k, Map.get(socket, k)} end)
    end
  end
end
