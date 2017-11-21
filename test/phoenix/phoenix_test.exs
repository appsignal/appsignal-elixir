defmodule UsingAppsignalPhoenix do
  def call(conn, _opts) do
    conn |> Plug.Conn.assign(:called?, true)
  end

  defoverridable [call: 2]

  use Appsignal.Phoenix
end

defmodule UsingAppsignalPhoenixWithException do
  def call(_conn, _opts) do
    raise "exception!"
  end

  defoverridable [call: 2]

  use Appsignal.Phoenix
end

defmodule UsingAppsignalPhoenixWithTimeout do
  def call(_conn, _opts) do
    Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)
  end

  defoverridable [call: 2]

  use Appsignal.Phoenix
end

defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.{Transaction, FakeTransaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link
    [fake_transaction: fake_transaction]
  end

  describe "concerning starting and finishing transactions" do
    setup do
      conn = UsingAppsignalPhoenix.call(%Plug.Conn{}, %{})

      {:ok, conn: conn}
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "calls super and returns the conn", context do
      assert context[:conn].assigns[:called?]
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end
  end

  describe "concerning catching errors" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, "foo")
      |> Plug.Conn.put_private(:phoenix_action, "bar")

      [conn: conn]
    end

    test "reports an error for an exception", %{conn: conn, fake_transaction: fake_transaction} do
      :ok = try do
        UsingAppsignalPhoenixWithException.call(conn, %{})
      catch
        :error, %RuntimeError{message: "exception!"} -> :ok
        type, reason -> {type, reason}
      end

      assert FakeTransaction.started_transaction?(fake_transaction)
      assert [{
        %Appsignal.Transaction{} = transaction,
        "RuntimeError",
        "HTTP request error: exception!",
        _stack
      }] = FakeTransaction.errors(fake_transaction)
      assert [transaction] == FakeTransaction.finished_transactions(fake_transaction)
      assert [transaction] == FakeTransaction.completed_transactions(fake_transaction)
    end

    test "reports an error for a timeout", %{conn: conn, fake_transaction: fake_transaction} do
      :ok = try do
        UsingAppsignalPhoenixWithTimeout.call(conn, %{})
      catch
        :exit, {:timeout, {Task, :await, _}} -> :ok
        type, reason -> {type, reason}
      end

      assert FakeTransaction.started_transaction?(fake_transaction)
      assert [{
        %Appsignal.Transaction{} = transaction,
        ":timeout",
        "HTTP request error: {:timeout, {Task, :await, [%Task{owner: " <> _,
        _stack
      }] = FakeTransaction.errors(fake_transaction)
      assert [transaction] == FakeTransaction.finished_transactions(fake_transaction)
      assert [transaction] == FakeTransaction.completed_transactions(fake_transaction)
    end
  end
end
