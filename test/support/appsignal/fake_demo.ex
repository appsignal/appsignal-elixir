defmodule Appsignal.FakeDemo do
  @behaviour Appsignal.DemoBehaviour
  use TestAgent
  alias Appsignal.Transaction

  def create_transaction_error_request do
    update(__MODULE__, :create_transaction_error_request, true)
    %Transaction{}
  end

  def create_transaction_performance_request do
    update(__MODULE__, :create_transaction_performance_request, true)
    %Transaction{}
  end
end
