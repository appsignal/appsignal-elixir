defmodule TestError do
  @moduledoc false
  defexception message: "Hello world! This is an error used for demonstration purposes."
end

defmodule Appsignal.Demo do
  @moduledoc false
  import Appsignal.Instrumentation, only: [instrument: 2, instrument: 3]

  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  def send_performance_sample do
    instrument("DemoController#hello", "call.phoenix", fn span ->
      span
      |> @span.set_namespace("http_request")
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
    end)
  end

  def send_error_sample do
    raise TestError
  catch
    kind, reason ->
      instrument("DemoController#hello", "call.phoenix", fn span ->
        span
        |> @span.set_namespace("http_request")
        |> @span.set_attribute("demo_sample", true)
        |> @span.set_sample_data("environment", %{"method" => "GET", "request_path" => "/"})
        |> @span.add_error(kind, reason, __STACKTRACE__)
      end)
  end
end
