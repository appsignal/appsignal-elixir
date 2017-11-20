defmodule Appsignal.FakeDemo do
  @behaviour Appsignal.DemoBehaviour
  use TestAgent

  def create_transaction_error_request do
    update(__MODULE__, :create_transaction_error_request, true)
  end

  def create_transaction_performance_request do
    update(__MODULE__, :create_transaction_performance_request, true)
  end
end
