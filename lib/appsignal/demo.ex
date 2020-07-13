defmodule TestError do
  @moduledoc false
  defexception message: "Hello world! This is an error used for demonstration purposes."
end

defmodule Appsignal.Demo do
  @moduledoc false
  import Appsignal.Instrumentation.Helpers, only: [instrument: 2]
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def send_performance_sample do
    span = create_demo_span()

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

  def send_error_sample do
    raise TestError
  catch
    kind, reason ->
      create_demo_span()
      |> @span.add_error(kind, reason, __STACKTRACE__)
      |> @tracer.close_span()
  end

  defp create_demo_span do
    "http_request"
    |> @tracer.create_span()
    |> @span.set_name("DemoController#hello")
    |> @span.set_attribute("demo_sample", true)
    |> @span.set_sample_data("environment", %{"method" => "GET", "request_path" => "/"})
  end
end
