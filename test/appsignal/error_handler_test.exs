defmodule Appsignal.ErrorHandlerTest do
  @moduledoc """
  Test the actual Appsignal.ErrorHandler
  """

  use ExUnit.Case, async: true

  alias Appsignal.{ErrorHandler, FakeTransaction, Transaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "whether we can send error reports with a current transaction", %{
    fake_transaction: fake_transaction
  } do
    pid =
      :proc_lib.spawn(fn ->
        self()
        |> inspect
        |> FakeTransaction.start(:http_request)
        |> FakeTransaction.set_action("AppsignalErrorHandlerTest#test")

        :erlang.error(:error_http_request)
      end)

    :timer.sleep(20)

    [{transaction, reason, _message, _stack}] = FakeTransaction.errors(fake_transaction)

    assert transaction.id == inspect(pid)
    assert reason == ":error_http_request"
  end

  test "does not send error reports for ignored processes", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      Appsignal.TransactionRegistry.ignore(self())
      :timer.sleep(50)

      :erlang.error(:error_ignored)
    end)

    :timer.sleep(100)

    refute fake_transaction
           |> FakeTransaction.errors()
           |> Enum.any?(fn error ->
             match?({%Transaction{}, ":error_ignored", _, _}, error)
           end)
  end

  test "submitting the transaction", %{fake_transaction: fake_transaction} do
    transaction = Transaction.start("id", :http_request)
    reason = "ArithmeticError"
    message = "bad argument in arithmetic expression"
    metadata = %{foo: "bar"}

    transaction = ErrorHandler.submit_transaction(transaction, reason, message, [], metadata)

    assert [{%Appsignal.Transaction{}, ^reason, ^message, _stack}] =
             FakeTransaction.errors(fake_transaction)

    assert ^metadata = FakeTransaction.metadata(fake_transaction)
    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  describe "handle_error/2" do
    test "adds an exception to the transaction and completes it", %{
      fake_transaction: fake_transaction
    } do
      transaction = FakeTransaction.create("123", :http_request)
      exception = %RuntimeError{}

      :ok = ErrorHandler.handle_error(transaction, exception, [], %{})

      assert [{^transaction, "RuntimeError", "runtime error", []}] =
               FakeTransaction.errors(fake_transaction)

      [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
    end

    test "normalizes errors before adding them to the transaction", %{
      fake_transaction: fake_transaction
    } do
      transaction = FakeTransaction.create("123", :http_request)
      :ok = ErrorHandler.handle_error(transaction, :undef, [], %{})

      assert [{^transaction, "UndefinedFunctionError", "undefined function", []}] =
               FakeTransaction.errors(fake_transaction)
    end

    test "adds request metadata to the transaction", %{fake_transaction: fake_transaction} do
      transaction = FakeTransaction.create("123", :http_request)
      exception = %RuntimeError{}
      conn = %Plug.Conn{}

      :ok = ErrorHandler.handle_error(transaction, exception, [], conn)

      assert conn == FakeTransaction.request_metadata(fake_transaction)
    end

    test "does not add request metadata for an unsampled transaction", %{
      fake_transaction: fake_transaction
    } do
      FakeTransaction.update(fake_transaction, :finish, :no_sample)

      transaction = FakeTransaction.create("123", :http_request)
      exception = %RuntimeError{}
      conn = %Plug.Conn{}

      :ok = ErrorHandler.handle_error(transaction, exception, [], conn)

      refute FakeTransaction.request_metadata(fake_transaction)
    end

    test "ignores errors with a plug_status lower than 500", %{fake_transaction: fake_transaction} do
      transaction = FakeTransaction.create("123", :http_request)
      exception = %Plug.BadRequestError{}

      :ok = ErrorHandler.handle_error(transaction, exception, [], %{})

      assert [] = FakeTransaction.errors(fake_transaction)
      refute FakeTransaction.completed_transactions(fake_transaction)
    end
  end
end
