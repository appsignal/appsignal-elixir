defmodule Appsignal.Phoenix.Template.ExsEngine do
  @behaviour Phoenix.Template.Engine

  def compile(path, name) do
    path
    |> Phoenix.Template.ExsEngine.compile(name)
    |> Appsignal.Phoenix.Template.compile(path)
  end
end
