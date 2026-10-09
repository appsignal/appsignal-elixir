if Code.ensure_loaded?(Phoenix.Template.EExEngine) do
  defmodule Appsignal.Phoenix.Template.EExEngine do
    alias Appsignal.Phoenix.Template
    alias Phoenix.Template.EExEngine

    @moduledoc false
    unless Code.ensure_loaded?(Phoenix.Template.EExEngine),
      do: @compile({:no_warn_undefined, Phoenix.Template.EExEngine})

    def compile(path, name) do
      path
      |> EExEngine.compile(name)
      |> Template.compile(path)
    end
  end
end
