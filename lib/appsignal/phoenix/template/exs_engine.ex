if Code.ensure_loaded?(Phoenix) do
  defmodule Appsignal.Phoenix.Template.ExsEngine do
    @moduledoc """
    Instruments template renders using the `.exs` extension.

    See the [Phoenix integration guide](phoenix.html) for information on
    how to instrument your templates.
    """

    use Appsignal.Phoenix.TemplateInstrumenter, engine: Phoenix.Template.ExsEngine
  end
end
