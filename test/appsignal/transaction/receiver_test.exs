defmodule Appsignal.Transaction.ReceiverTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Transaction, Transaction.ETS, Transaction.Receiver}

  test "monitors a process, and demonitors it when it goes DOWN" do
    task =
      %Task{pid: pid} =
      Task.async(fn ->
        ETS.insert({self(), %Transaction{}, Receiver.monitor(self())})
      end)

    Task.await(task)

    assert [{^pid, %Appsignal.Transaction{}, reference}] = ETS.lookup(pid)
    assert is_reference(reference)

    until(fn ->
      assert [] = ETS.lookup(pid)
    end)
  end

  test "monitors a process, and demonitors it when its transaction is completed" do
    transaction = Transaction.start("monitor", :test)

    assert monitored_processes() == [self()]
    Transaction.complete(transaction)

    until(fn ->
      assert monitored_processes() == []
    end)
  end

  defp monitored_processes do
    {:monitors, monitors} =
      Receiver
      |> Process.whereis()
      |> Process.info(:monitors)

    Enum.map(monitors, fn {:process, pid} -> pid end)
  end
end
