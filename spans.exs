defmodule SpanGenerator do
  def span do
    parent = Appsignal.Tracer.create_span("http_request")

    parent
    |> Appsignal.Span.set_name("HomepageController#show")
    |> Appsignal.Span.set_namespace("http_request")
    |> Appsignal.Span.set_attribute("boolean", true)
    |> Appsignal.Span.set_attribute("string", "string")
    |> Appsignal.Span.set_attribute("integer", 42)
    |> Appsignal.Span.set_attribute("float", 3.14)
    |> Appsignal.Span.set_sql("SELECT * FROM USERS")
    |> Appsignal.Span.set_sample_data("params", %{foo: "bar"})

    try do
      raise "Exception!"
    catch
      kind, reason ->
        Appsignal.Span.add_error(parent, kind, reason, __STACKTRACE__)
    end

    "http_request"
    |> Appsignal.Tracer.create_span(parent)
    |> Appsignal.Tracer.close_span()

    Appsignal.Tracer.close_span(parent)
  end
end

SpanGenerator.span()
