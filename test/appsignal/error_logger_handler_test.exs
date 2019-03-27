defmodule Appsignal.ErrorLoggerHandlerTest do
  alias Appsignal.{FakeTransaction, Transaction}
  import AppsignalTest.Utils
  use ExUnit.Case, async: false

  setup do
    Appsignal.remove_report_handler()
    Appsignal.ErrorLoggerHandler.add()

    on_exit(fn ->
      Appsignal.ErrorLoggerHandler.remove()
      Appsignal.add_report_handler()
    end)

    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "handles an error report", %{fake_transaction: fake_transaction} do
    pid =
      :proc_lib.spawn(fn ->
        self()
        |> inspect
        |> FakeTransaction.start(:http_request)
        |> FakeTransaction.set_action("AppsignalErrorHandlerTest#test")

        :erlang.error(:error_http_request)
      end)

    [{transaction, reason, _, _}] =
      with_retries(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

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

  test "does not cause warnings for noise on handle_info" do
    :error_logger.add_report_handler(ErrorLoggerForwarder, self())

    :error_logger
    |> Process.whereis()
    |> send(:noise)

    refute_receive({:warning_msg, _, _})
  end
end
