defmodule Appsignal.Phoenix.Template do
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @moduledoc false

  def compile(fun, path) do
    quote do
      Appsignal.instrument("Render #{unquote(path)}", fn span ->
        unquote(@span).set_attribute(span, "title", unquote(path))
        unquote(@span).set_attribute(span, "appsignal:category", "render.phoenix_template")
        unquote(fun)
      end)
    end
  end
end
