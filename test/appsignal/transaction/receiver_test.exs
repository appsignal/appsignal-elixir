defmodule Appsignal.Transaction.ReceiverTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Transaction, Transaction.ETS, Transaction.Receiver}

  test "monitors a process" do
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
end
