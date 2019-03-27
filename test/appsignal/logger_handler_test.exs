if System.otp_release() >= "21" do
  defmodule Appsignal.LoggerHandlerTest do
    alias Appsignal.{FakeTransaction, Transaction}
    use ExUnit.Case, async: false
    import AppsignalTest.Utils

    setup do
      Appsignal.remove_report_handler()
      Appsignal.LoggerHandler.add()

      on_exit(fn ->
        Appsignal.LoggerHandler.remove()
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

    test "does not send error reports for ignored processes", %{
      fake_transaction: fake_transaction
    } do
      :proc_lib.spawn(fn ->
        Appsignal.TransactionRegistry.ignore(self())
        :timer.sleep(50)

        :erlang.error(:error_ignored)
      end)

      repeatedly(fn ->
        refute fake_transaction
               |> FakeTransaction.errors()
               |> Enum.any?(fn error ->
                 match?({%Transaction{}, ":error_ignored", _, _}, error)
               end)
      end)
    end
  end
end
