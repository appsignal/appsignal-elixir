defmodule Appsignal.Phoenix.Template.ExsEngine do
  @behaviour Phoenix.Template.Engine

  def compile(path, name) do
    fun = Phoenix.Template.ExsEngine.compile(path, name)

    quote do
      Appsignal.instrument("render.phoenix_template", fn -> unquote(fun) end)
    end
  end
end
