defmodule UsingAppsignalPhoenix do
  def call(conn, _opts) do
    conn |> Plug.Conn.assign(:called?, true)
  end

  defoverridable [call: 2]

  use Appsignal.Phoenix.Plug
end

defmodule Appsignal.Phoenix.PlugTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    FakeTransaction.start_link
    :ok
  end

  describe "for a :sample transaction" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, "foo")
      |> Plug.Conn.put_private(:phoenix_action, "bar")
      |> UsingAppsignalPhoenix.call(%{})

      {:ok, conn: conn}
    end

    test "starts a transaction" do
      assert FakeTransaction.started_transaction?
    end

    test "calls super and returns the conn", context do
      assert context[:conn].assigns[:called?]
    end

    test "sets the transaction's action name" do
      assert "foo#bar" == FakeTransaction.action
    end

    test "finishes the transaction" do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions
    end

    test "sets the transaction's request metadata", context do
      assert context[:conn] == FakeTransaction.request_metadata
    end

    test "completes the transaction" do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions
    end
  end

  describe "for a :no_sample transaction" do
    setup do
      FakeTransaction.set_finish(:no_sample)

      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, "foo")
      |> Plug.Conn.put_private(:phoenix_action, "bar")
      |> UsingAppsignalPhoenix.call(%{})

      {:ok, conn: conn}
    end

    test "does not set the transaction's request metadata" do
      assert nil == FakeTransaction.request_metadata
    end
  end
end
