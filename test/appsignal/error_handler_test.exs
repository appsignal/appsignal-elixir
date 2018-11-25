defmodule Appsignal.ErrorHandlerTest do
  @moduledoc """
  Test the actual Appsignal.ErrorHandler
  """

  use ExUnit.Case, async: true

  alias Appsignal.{Transaction, ErrorHandler, FakeTransaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "whether we can send error reports without current transaction" do
    :proc_lib.spawn(fn ->
      :erlang.error(:error_task)
    end)

    :timer.sleep(100)
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
    id = Transaction.generate_id()

    :proc_lib.spawn(fn ->
      Transaction.start(id, :http_request)

      Appsignal.TransactionRegistry.ignore(self())

      :erlang.error(:error_http_request)
    end)

    :timer.sleep(50)

    assert FakeTransaction.errors(fake_transaction) == []
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

  test "does not cause warnings for noise on handle_info" do
    :error_logger.add_report_handler(ErrorLoggerForwarder, self())

    :error_logger
    |> Process.whereis()
    |> send(:noise)

    refute_receive({:warning_msg, _, _})
  end
end
