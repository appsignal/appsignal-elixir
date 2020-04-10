defmodule Appsignal.Phoenix.Template.EExEngine do
  @behaviour Phoenix.Template.Engine

  def compile(path, name) do
    path
    |> Phoenix.Template.EExEngine.compile(name)
    |> Appsignal.Phoenix.Template.compile(path)
  end
end
