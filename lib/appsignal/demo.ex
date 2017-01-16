defmodule Appsignal.Demo do
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  @doc false
  def create_transaction_error_request do
    transaction = create_demo_transaction()
    Appsignal.Transaction.set_error(
      transaction,
      "TestError",
      "Hello world! This is an error used for demonstration purposes.",
      System.stacktrace
    )

    finish_demo_transaction(transaction)
  end

  @doc false
  def create_transaction_performance_request do
    transaction = create_demo_transaction()

    instrument(transaction, "template.render", "Rendering something slow", fn() ->
      :timer.sleep(1000)
      instrument(transaction, "ecto.query", "Slow query", fn() ->
        :timer.sleep(300)
      end)
      instrument(transaction, "ecto.query", "Slow query", fn() ->
        :timer.sleep(500)
      end)
      instrument(transaction, "template.render", "Rendering something slow", fn() ->
        :timer.sleep(100)
      end)
    end)

    finish_demo_transaction(transaction)
  end

  defp create_demo_transaction do
    Appsignal.Transaction.start(
      Appsignal.Transaction.generate_id,
      :http_request
    )
    |> Appsignal.Transaction.set_action("DemoController#hello")
    |> Appsignal.Transaction.set_meta_data("demo_sample", "true")
    |> Appsignal.Transaction.set_meta_data("path", "/hello")
    |> Appsignal.Transaction.set_meta_data("method", "GET")
  end

  defp finish_demo_transaction(transaction) do
    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end
end
