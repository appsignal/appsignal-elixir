defmodule Appsignal.Demo do
  import Appsignal, only: [instrument: 2]
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def send_performance_sample() do
    span =
      "http_request"
      |> @tracer.create_span()
      |> @span.set_name("DemoController#hello")
      |> @span.set_attribute("demo_sample", true)
      |> @span.set_sample_data("environment", %{"method" => "GET", "request_path" => "/"})

    instrument("call.phoenix_endpoint", fn ->
      :timer.sleep(100)

      instrument("query.ecto", fn ->
        :timer.sleep(30)
      end)

      instrument("query.ecto", fn ->
        :timer.sleep(50)
      end)

      instrument("render.phoenix_template", fn ->
        :timer.sleep(10)
      end)
    end)

    @tracer.close_span(span)
  end
end
