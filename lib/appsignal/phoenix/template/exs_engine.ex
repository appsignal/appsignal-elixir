defmodule Appsignal.Phoenix.Template.ExsEngine do
  alias Appsignal.Phoenix.Template
  alias Phoenix.Template.ExsEngine

  @behaviour Phoenix.Template.Engine
  @moduledoc false

  def compile(path, name) do
    path
    |> ExsEngine.compile(name)
    |> Template.compile(path)
  end
end
