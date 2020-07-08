defmodule Appsignal.Instrumentation.Helpers do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @doc false
  def instrument(fun) do
    span = @tracer.create_span("http_request", @tracer.current_span)

    result = call_with_optional_argument(fun, span)
    @tracer.close_span(span)

    result
  end

  @doc """
  Instrument a function.

      def call do
        Appsignal.instrument("foo.bar", fn ->
          :timer.sleep(1000)
        end)
      end

  When passing a function that takes an argument, the function is called with
  the created span to allow adding extra information.

      def call(params) do
        Appsignal.instrument("foo.bar", fn span ->
          Appsignal.Span.set_sample_data(span, "params", params)
          :timer.sleep(1000)
        end)
      end

  """
  def instrument(name, fun) do
    instrument(fn span ->
      @span.set_name(span, name)
      call_with_optional_argument(fun, span)
    end)
  end

  defp call_with_optional_argument(fun, argument) do
    case fun
         |> :erlang.fun_info()
         |> Keyword.get(:arity) do
      0 -> fun.()
      _ -> fun.(argument)
    end
  end
end
