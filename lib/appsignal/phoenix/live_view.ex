if Appsignal.live_view?() do
  defmodule Appsignal.Phoenix.LiveView do
    alias Appsignal.{ErrorHandler, Transaction, TransactionRegistry, Utils.MapFilter}
    import Appsignal.Utils
    @transaction Application.get_env(:appsignal, :appsignal_transaction, Transaction)

    @doc """
    Record a live_view action.
    """
    @spec live_view_action(atom, String.t(), Phoenix.LiveView.Socket.t(), fun) :: any
    def live_view_action(module, name, %Phoenix.LiveView.Socket{} = socket, function) do
      live_view_action(module, name, socket, %{}, function)
    end

    @spec live_view_action(atom, String.t(), Phoenix.LiveView.Socket.t(), map, fun) :: any
    def live_view_action(module, name, %Phoenix.LiveView.Socket{} = socket, params, function) do
      transaction =
        @transaction.generate_id()
        |> @transaction.start(:live_view)
        |> @transaction.set_action("#{module_name(module)}##{name}")

      try do
        function.()
      catch
        kind, reason ->
          stacktrace = System.stacktrace()
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

    @spec finish_with_socket(Transaction.t() | nil, Phoenix.LiveView.Socket.t(), map()) ::
            :ok | nil
    defp finish_with_socket(transaction, socket, params) do
      if @transaction.finish(transaction) == :sample do
        transaction
        |> @transaction.set_sample_data("params", MapFilter.filter_parameters(params))
        |> @transaction.set_sample_data("environment", request_environment(socket))
      end

      @transaction.complete(transaction)
    end

    @socket_fields ~w(id root_view view endpoint router)a
    @spec request_environment(Phoenix.LiveView.Socket.t()) :: map
    defp request_environment(socket) do
      @socket_fields
      |> Enum.into(%{}, fn k -> {k, Map.get(socket, k)} end)
    end
  end
end
