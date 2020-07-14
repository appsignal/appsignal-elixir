defmodule Appsignal.Phoenix.Template.EExEngine do
  alias Appsignal.Phoenix.Template
  alias Phoenix.Template.EExEngine

  @behaviour Phoenix.Template.Engine
  @moduledoc false

  def compile(path, name) do
    path
    |> EExEngine.compile(name)
    |> Template.compile(path)
  end
end
