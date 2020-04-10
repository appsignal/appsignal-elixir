defmodule Appsignal.Phoenix.Template do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def compile(fun, path) do
    quote do
      Appsignal.instrument("render.phoenix_template", fn span ->
        unquote(@span).set_attribute(span, "title", unquote(path))
        unquote(fun)
      end)
    end
  end
end
