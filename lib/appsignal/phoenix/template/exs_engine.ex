defmodule Appsignal.Phoenix.Template.ExsEngine do
  alias Appsignal.Phoenix.Template
  alias Phoenix.Template.ExsEngine

  @moduledoc false
  unless Code.ensure_loaded?(Phoenix.Template.ExsEngine),
    do: @compile({:no_warn_undefined, Phoenix.Template.ExsEngine})

  def compile(path, name) do
    path
    |> ExsEngine.compile(name)
    |> Template.compile(path)
  end
end
