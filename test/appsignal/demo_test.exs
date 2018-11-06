defmodule AppsignalDemoTest do
  use ExUnit.Case, async: true
  import Mock

  test_with_mock "sends a demonstration error", Appsignal.Transaction, [:passthrough], [] do
    t = Appsignal.Demo.create_transaction_error_request()

    assert called(Appsignal.Transaction.set_action(t, "DemoController#hello"))

    assert called(
             Appsignal.Transaction.set_error(
               t,
               "TestError",
               "Hello world! This is an error used for demonstration purposes.",
               :_
             )
           )

    assert called(Appsignal.Transaction.set_meta_data(t, "demo_sample", "true"))
    assert called(Appsignal.Transaction.finish(t))
    assert called(Appsignal.Transaction.complete(t))
  end

  test_with_mock "sends a performance issue", Appsignal.Transaction, [:passthrough], [] do
    t = Appsignal.Demo.create_transaction_performance_request()

    assert called(Appsignal.Transaction.set_action(t, "DemoController#hello"))
    assert called(Appsignal.Transaction.set_meta_data(t, "demo_sample", "true"))
    assert called(Appsignal.Transaction.start_event(t))

    assert called(
             Appsignal.Transaction.finish_event(
               t,
               "render.phoenix_template",
               "Rendering something slow",
               "",
               0
             )
           )

    assert called(Appsignal.Transaction.finish(t))
    assert called(Appsignal.Transaction.complete(t))
  end
end
