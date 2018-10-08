if Appsignal.phoenix?() do
  defmodule Appsignal.Phoenix.Template.EExEngine do
    @moduledoc """
    Instruments template renders using the `.eex` extension.

    See the [Phoenix integration
    guide](http://docs.appsignal.com/elixir/integrations/phoenix.html) for
    information on how to instrument your templates.
    """

    use Appsignal.Phoenix.TemplateInstrumenter, engine: Phoenix.Template.EExEngine
  end
end
