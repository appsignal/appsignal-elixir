defmodule Appsignal.DemoBehaviour do
  @callback create_transaction_error_request :: nil
  @callback create_transaction_performance_request :: nil
end

defmodule Appsignal.Demo do
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  @behaviour Appsignal.DemoBehaviour

  @doc false
  def create_transaction_error_request do
    create_demo_transaction()
    |> Appsignal.Transaction.set_error(
      "TestError",
      "Hello world! This is an error used for demonstration purposes.",
      System.stacktrace
    )
    |> finish_demo_transaction()
  end

  @doc false
  def create_transaction_performance_request do
    transaction = create_demo_transaction()

    instrument(transaction, "render.phoenix_template", "Rendering something slow", fn() ->
      :timer.sleep(1000)
      instrument(transaction, "query.ecto", "Slow query", fn() ->
        :timer.sleep(300)
      end)
      instrument(transaction, "query.ecto", "Slow query", fn() ->
        :timer.sleep(500)
      end)
      instrument(transaction, "render.phoenix_template", "Rendering something slow", fn() ->
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
    |> Appsignal.Transaction.set_sample_data(
      "environment", %{request_path: "/hello", method: "GET"}
    )
  end

  defp finish_demo_transaction(transaction) do
    Appsignal.Transaction.finish(transaction)
    :ok = Appsignal.Transaction.complete(transaction)
  end
end
