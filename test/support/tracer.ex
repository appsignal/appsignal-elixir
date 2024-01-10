defmodule Appsignal.Support.Tracer do
  @spec custom_on_create_fun(nil | Appsignal.Span.t(), any()) :: nil | Appsignal.Span.t()
  def custom_on_create_fun(span, _parent) do
    Appsignal.Span.set_sample_data(span, "custom_data", %{foo: "bar"})
  end
end
