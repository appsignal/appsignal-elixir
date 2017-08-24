defmodule Appsignal.NifTest do
  use ExUnit.Case

  test "whether the agent starts" do
    assert :ok = Appsignal.Nif.start
  end

  test "whether the agent stops" do
    assert :ok = Appsignal.Nif.stop
  end

  if System.otp_release >= "20" do
    test "starting transaction returns a reference to the transaction resource" do
      assert {:ok, transaction} = Appsignal.Nif.start_transaction("transaction id", "http_request")
      assert is_reference(transaction)
    end
  else
    test "starting transaction returns a resource term" do
      assert {:ok, transaction} = Appsignal.Nif.start_transaction("transaction id", "http_request")
      assert is_binary(transaction)
    end
  end

  if not(Mix.env in [:test_no_nif]) do
    test "the nif is loaded" do
      assert true == Appsignal.Nif.loaded?
    end
  end

  if Mix.env in [:test_no_nif] do
    test "the nif is not loaded" do
      assert false == Appsignal.Nif.loaded?
    end
  end

end
