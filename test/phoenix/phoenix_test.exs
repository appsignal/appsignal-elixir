defmodule PhoenixWithAppSignal do
  use Plug.Router
  use Appsignal.Phoenix
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/exception" do
    raise("Exception!")
    send_resp(conn, 200, "Welcome")
  end
end

defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction
  use Plug.Test

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  describe "concerning starting and finishing transactions" do
    setup do
      conn =
        :get
        |> conn("/", "")
        |> PhoenixWithAppSignal.call([])

      [conn: conn]
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "returns the updated conn", %{conn: conn} do
      assert conn.state == :sent
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end
  end

  describe "concerning catching errors" do
    setup do
      try do
        :get
        |> conn("/exception", %{})
        |> PhoenixWithAppSignal.call([])
      catch
        :error, %Plug.Conn.WrapperError{reason: %RuntimeError{message: "Exception!"}} ->
          :ok

        type, reason ->
          {type, reason}
      end
    end

    test "reports an error for an exception", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)

      assert [
               {
                 %Appsignal.Transaction{} = transaction,
                 "RuntimeError",
                 "Exception!",
                 _stack
               }
             ] = FakeTransaction.errors(fake_transaction)

      assert [transaction] == FakeTransaction.finished_transactions(fake_transaction)
      assert [transaction] == FakeTransaction.completed_transactions(fake_transaction)
    end
  end
end
