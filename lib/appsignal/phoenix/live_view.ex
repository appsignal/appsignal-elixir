if Appsignal.live_view?() do
  defmodule Appsignal.Phoenix.LiveView do
    alias Appsignal.{ErrorHandler, Stacktrace, Transaction, TransactionRegistry, Utils.MapFilter}
    import Appsignal.Utils
    require Appsignal.Stacktrace
    @transaction Application.get_env(:appsignal, :appsignal_transaction, Transaction)

    @moduledoc """
    Instrumentation for LiveView actions

    ## Instrumenting a LiveView action

    A LiveView action is instrumented by wrapping its contents in a
    `Appsignal.Phoenix.LiveView.live_view_action/4` block.

        defmodule AppsignalPhoenixExampleWeb.ClockLive do
          use Phoenix.LiveView

          def render(assigns) do
            AppsignalPhoenixExampleWeb.ClockView.render("index.html", assigns)
          end

          def mount(_session, socket) do
            :timer.send_interval(1000, self(), :tick)
            {:ok, assign(socket, state: Time.utc_now())}
          end


          def handle_info(:tick, socket) do
            {:ok, assign(socket, state: Time.utc_now())}
          end
        end

    Given a live view that updates its own state every second, we can add
    AppSignal instrumentation by wrapping both the mount/2 and handle_info/2
    functions with a `Appsignal.Phoenix.LiveView.live_view_action`/4 call:

        defmodule AppsignalPhoenixExampleWeb.ClockLive do
          use Phoenix.LiveView
          import Appsignal.Phoenix.LiveView, only: [live_view_action: 4]

          def render(assigns) do
            AppsignalPhoenixExampleWeb.ClockView.render("index.html", assigns)
          end

          def mount(_session, socket) do
            live_view_action(__MODULE__, :mount, socket, fn ->
              :timer.send_interval(1000, self(), :tick)
              {:ok, assign(socket, state: Time.utc_now())}
            end)
          end

          def handle_info(:tick, socket) do
            live_view_action(__MODULE__, :mount, socket, fn ->
              {:ok, assign(socket, state: Time.utc_now())}
            end)
          end
        end

    Calling one of these functions in your app will now automatically create a
    sample that's sent to AppSignal. These are displayed under the `:live_view`
    namespace.

    For more fine-grained performance instrumentation, use the instrumentation
    helper functions in `Appsignal.Instrumentation.Helpers`.
    """

    @doc """
    Record a live_view action.
    """
    @spec live_view_action(atom, String.t(), Phoenix.LiveView.Socket.t(), fun) :: any
    def live_view_action(module, name, %Phoenix.LiveView.Socket{} = socket, function) do
      live_view_action(module, name, socket, %{}, function)
    end

    @spec live_view_action(atom, String.t(), Phoenix.LiveView.Socket.t(), map, fun) :: any
    def live_view_action(module, name, %Phoenix.LiveView.Socket{} = socket, params, function) do
      if Appsignal.Config.active?() do
        transaction =
          @transaction.generate_id()
          |> @transaction.start(:live_view)
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
      else
        function.()
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
