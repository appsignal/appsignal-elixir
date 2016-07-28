defmodule Appsignal.Phoenix.Template.ExsEngine do
  @moduledoc """
  Instruments template renders using the `.exs` extension.
  """

  use Appsignal.Phoenix.TemplateInstrumenter, engine: Phoenix.Template.ExsEngine

end
