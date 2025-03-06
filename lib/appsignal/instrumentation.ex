defmodule Appsignal.Instrumentation do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @spec instrument(function()) :: any()
  @doc false
  def instrument(fun) do
    span = @tracer.create_span("background_job", @tracer.current_span)

    result =
      try do
        call_with_optional_argument(fun, span)
      after
        @tracer.close_span(@tracer.current_span())
      end

    result
  end

  @spec instrument(String.t(), function()) :: any()
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
    instrument(name, name, fun)
  end

  @spec instrument(String.t(), String.t(), function()) :: any()
  @doc """
  Instrument a function, and set the `"appsignal:category"` attribute to the
  value passed as the `category` argument.
  """
  def instrument(name, category, fun) do
    instrument(fn span ->
      _ =
        span
        |> @span.set_name(name)
        |> @span.set_attribute("appsignal:category", category)

      call_with_optional_argument(fun, span)
    end)
  end

  @deprecated "Use Appsignal.instrument/3 instead."
  def instrument(_, name, category, fun) do
    instrument(name, category, fun)
  end

  @spec instrument_root(String.t(), String.t(), function()) :: any()
  @doc false
  def instrument_root(namespace, name, fun) do
    span = @tracer.create_span(namespace, nil)

    span
    |> @span.set_name(name)
    |> @span.set_attribute("appsignal:category", name)

    result =
      try do
        call_with_optional_argument(fun, span)
      after
        @tracer.close_span(span)
      end

    result
  end

  @spec set_error(Exception.t(), Exception.stacktrace()) :: Appsignal.Span.t() | nil
  @doc """
  Set an error in the current root span.
  """
  def set_error(%_{__exception__: true} = exception, stacktrace) do
    @span.add_error(@tracer.root_span(), exception, stacktrace)
  end

  @spec set_error(Exception.kind(), any(), Exception.stacktrace()) :: Appsignal.Span.t() | nil
  @doc """
  Set an error in the current root span by passing a `kind` and `reason`.
  """
  def set_error(kind, reason, stacktrace) do
    @span.add_error(@tracer.root_span(), kind, reason, stacktrace)
  end

  @spec send_error(Exception.t(), Exception.stacktrace()) :: Appsignal.Span.t() | nil
  @doc """
  Send an error in a newly created `Appsignal.Span`.
  """
  def send_error(%_{__exception__: true} = exception, stacktrace) do
    send_error(exception, stacktrace, & &1)
  end

  @spec send_error(Exception.t(), Exception.stacktrace(), function()) :: Appsignal.Span.t() | nil
  @doc """
  Send an error in a newly created `Appsignal.Span`. Calls the passed function
  with the created `Appsignal.Span` before closing it.
  """
  def send_error(%_{__exception__: true} = exception, stacktrace, fun) when is_function(fun) do
    @span.create_root("http_request", self())
    |> @span.add_error(exception, stacktrace)
    |> fun.()
    |> @span.close()
  end

  @spec send_error(Exception.kind(), any(), Exception.stacktrace()) :: Appsignal.Span.t() | nil
  def send_error(kind, reason, stacktrace) do
    send_error(kind, reason, stacktrace, & &1)
  end

  def send_error(kind, reason, stacktrace, fun) do
    @span.create_root("http_request", self())
    |> @span.add_error(kind, reason, stacktrace)
    |> fun.()
    |> @span.close()
  end

  defp call_with_optional_argument(fun, _argument) when is_function(fun, 0), do: fun.()
  defp call_with_optional_argument(fun, argument) when is_function(fun, 1), do: fun.(argument)
end
