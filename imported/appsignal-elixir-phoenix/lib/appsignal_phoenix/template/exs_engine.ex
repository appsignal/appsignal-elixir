defmodule Appsignal.Phoenix.Template.ExsEngine do
  @behaviour Phoenix.Template.Engine
  @moduledoc false

  def compile(path, name) do
    path
    |> Phoenix.Template.ExsEngine.compile(name)
    |> Appsignal.Phoenix.Template.compile(path)
  end
end
