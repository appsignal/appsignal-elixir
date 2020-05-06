defmodule Appsignal.Phoenix.Template.EExEngine do
  @behaviour Phoenix.Template.Engine
  @moduledoc false

  def compile(path, name) do
    path
    |> Phoenix.Template.EExEngine.compile(name)
    |> Appsignal.Phoenix.Template.compile(path)
  end
end
