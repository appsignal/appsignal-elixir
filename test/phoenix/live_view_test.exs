if Appsignal.live_view?() do
  defmodule InstrumentedPhoenixLiveView do
    import Phoenix.LiveView, only: [assign: 2]
    import Appsignal.Phoenix.LiveView, only: [live_view_action: 4, live_view_action: 5]

    def action(:tick = action, params, socket) do
      live_view_action(__MODULE__, action, socket, params, fn ->
        assign(socket, called?: true)
      end)
    end

    def action(:tick = action, socket) do
      live_view_action(__MODULE__, action, socket, fn ->
        assign(socket, called?: true)
      end)
    end

    def action(:exception = action, socket) do
      live_view_action(__MODULE__, action, socket, fn ->
        raise "Exception!"
      end)
    end
  end

  defmodule Appsignal.Phoenix.LiveViewTest do
    import AppsignalTest.Utils
    alias Appsignal.FakeTransaction
    use ExUnit.Case

    setup do
      {:ok, fake_transaction} = FakeTransaction.start_link()

      socket = %Phoenix.LiveView.Socket{
        endpoint: AppsignalPhoenixExampleWeb.Endpoint,
        id: 1,
        root_view: AppsignalPhoenixExampleWeb.ClockLive,
        router: AppsignalPhoenixExampleWeb.Router,
        view: AppsignalPhoenixExampleWeb.ClockLive
      }

      [fake_transaction: fake_transaction, socket: socket]
    end

    describe "instruments a live view action with the instrumentation helper" do
      setup %{socket: socket} do
        [socket: InstrumentedPhoenixLiveView.action(:tick, socket)]
      end

      test "starts a transaction", %{fake_transaction: fake_transaction} do
        assert FakeTransaction.started_transactions(fake_transaction) == [{"123", :live_view}]
      end

      test "returns the updated socket", %{socket: socket} do
        assert socket.assigns == %{called?: true}
      end

      test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
        assert "InstrumentedPhoenixLiveView#tick" ==
                 FakeTransaction.action(fake_transaction)
      end

      test "finishes the transaction", %{fake_transaction: fake_transaction} do
        assert [%Appsignal.Transaction{}] =
                 FakeTransaction.finished_transactions(fake_transaction)
      end

      test "sets the transaction's sample data", %{fake_transaction: fake_transaction} do
        assert %{
                 "environment" => %{
                   endpoint: AppsignalPhoenixExampleWeb.Endpoint,
                   id: 1,
                   root_view: AppsignalPhoenixExampleWeb.ClockLive,
                   router: AppsignalPhoenixExampleWeb.Router,
                   view: AppsignalPhoenixExampleWeb.ClockLive
                 },
                 "params" => %{}
               } == FakeTransaction.sample_data(fake_transaction)
      end

      test "completes the transaction", %{fake_transaction: fake_transaction} do
        assert [%Appsignal.Transaction{}] =
                 FakeTransaction.completed_transactions(fake_transaction)
      end
    end

    describe "instruments a live view action with the instrumentation helper, with passed parameters" do
      setup %{socket: socket} do
        [socket: InstrumentedPhoenixLiveView.action(:tick, %{"foo" => "bar"}, socket)]
      end

      test "sets the transaction's sample data", %{fake_transaction: fake_transaction} do
        assert %{
                 "environment" => %{
                   endpoint: AppsignalPhoenixExampleWeb.Endpoint,
                   id: 1,
                   root_view: AppsignalPhoenixExampleWeb.ClockLive,
                   router: AppsignalPhoenixExampleWeb.Router,
                   view: AppsignalPhoenixExampleWeb.ClockLive
                 },
                 "params" => %{"foo" => "bar"}
               } == FakeTransaction.sample_data(fake_transaction)
      end
    end

    describe "instruments a live view action with the instrumentation helper, with an exception" do
      setup %{socket: socket} do
        :ok =
          try do
            InstrumentedPhoenixLiveView.action(:exception, socket)
          catch
            :error, %RuntimeError{message: "Exception!"} -> :ok
            type, reason -> {type, reason}
          end
      end

      test "starts a transaction", %{fake_transaction: fake_transaction} do
        assert FakeTransaction.started_transactions(fake_transaction) == [{"123", :live_view}]
      end

      test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
        assert "InstrumentedPhoenixLiveView#exception" ==
                 FakeTransaction.action(fake_transaction)
      end

      test "finishes the transaction", %{fake_transaction: fake_transaction} do
        assert [%Appsignal.Transaction{}] =
                 FakeTransaction.finished_transactions(fake_transaction)
      end

      test "sets the transaction's sample data", %{fake_transaction: fake_transaction} do
        assert %{
                 "environment" => %{
                   endpoint: AppsignalPhoenixExampleWeb.Endpoint,
                   id: 1,
                   root_view: AppsignalPhoenixExampleWeb.ClockLive,
                   router: AppsignalPhoenixExampleWeb.Router,
                   view: AppsignalPhoenixExampleWeb.ClockLive
                 },
                 "params" => %{}
               } == FakeTransaction.sample_data(fake_transaction)
      end

      test "completes the transaction", %{fake_transaction: fake_transaction} do
        assert [%Appsignal.Transaction{}] =
                 FakeTransaction.completed_transactions(fake_transaction)
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
        until(fn ->
          assert Appsignal.TransactionRegistry.lookup(self()) == :ignored
        end)
      end
    end

    describe "when AppSignal is disabled" do
      setup %{socket: socket} do
        new_socket =
          AppsignalTest.Utils.with_config(%{active: false}, fn ->
            InstrumentedPhoenixLiveView.action(:tick, socket)
          end)

        [socket: new_socket]
      end

      test "does not start a transaction", %{fake_transaction: fake_transaction} do
        refute FakeTransaction.started_transaction?(fake_transaction)
      end

      test "returns the updated socket", %{socket: socket} do
        assert socket.assigns == %{called?: true}
      end

      test "does not finish the transaction", %{fake_transaction: fake_transaction} do
        assert [] = FakeTransaction.finished_transactions(fake_transaction)
      end
    end
  end
end
