defmodule Appsignal.Phoenix.Template.EExEngine do
  @behaviour Phoenix.Template.Engine

  def compile(path, name) do
    fun = Phoenix.Template.EExEngine.compile(path, name)

    quote do
      Appsignal.instrument("render.phoenix_template", fn -> unquote(fun) end)
    end
  end
end
