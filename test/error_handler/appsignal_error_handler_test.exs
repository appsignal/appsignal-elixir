defmodule AppsignalErrorHandlerTest do
  @moduledoc """
  Test the actual Appsignal.ErrorHandler
  """

  use ExUnit.Case, async: false
  import Mock

  alias Appsignal.Transaction

  # test "whether the error handler is installed" do
  #   assert :ok =
  #     :error_logger.delete_report_handler(Appsignal.ErrorHandler)
  #   assert {:error, :module_not_found} =
  #     :error_logger.delete_report_handler(Appsignal.ErrorHandler)
  # end


  test "wether we can send error reports without current transaction" do
    Task.start(fn() ->
      :erlang.error(:error_task)
    end)

    :timer.sleep 100
  end


  test "wether we can send error reports with a current transaction" do

    id = Transaction.generate_id()

    Task.start(fn() ->
      Transaction.start(id, :http_request)
      |> Transaction.set_action("AppsignalErrorHandlerTest#test")

      :erlang.error(:error_http_request)
    end)

    :timer.sleep 400
    # check that the handler has processed the transaction


    transaction = Appsignal.ErrorHandler.get_last_transaction
    assert %Transaction{} = transaction
    assert id == transaction.id

  end

  test_with_mock "submitting the transaction", Appsignal.Transaction, [:passthrough], [] do
    transaction = Transaction.start("id", :http_request)
    reason = "ArithmeticError"
    message = "bad argument in arithmetic expression"
    stacktrace = System.stacktrace
    metadata = %{foo: "bar"}
    conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}}

    Appsignal.ErrorHandler.submit_transaction(
      transaction,
      reason,
      message,
      stacktrace,
      metadata,
      conn
    )

    assert called Transaction.set_error(transaction, reason, message, stacktrace)
    assert called Transaction.set_request_metadata(transaction, conn)
    assert called Transaction.set_meta_data(metadata)
    assert called Transaction.finish(transaction)
    assert called Transaction.complete(transaction)
  end
end
