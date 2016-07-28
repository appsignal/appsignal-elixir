defmodule Appsignal.Phoenix.Template.EExEngine do
  @moduledoc """
  Instruments template renders using the `.eex` extension.
  """

  use Appsignal.Phoenix.TemplateInstrumenter, engine: Phoenix.Template.EExEngine

end
