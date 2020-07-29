defmodule Appsignal.Phoenix.View do
  @moduledoc """
  AppSignal.Phoenix.View instruments template rendering.

  ## Installation

  To install `Appsignal.Phoenix.View` into your Phoenix application, `use
  Appsignal.Phoenix.View` in your application's view function in the web
  module, after the existing `use Phoenix.View` line:

    defmodule AppsignalPhoenixExampleWeb do
      # ...

      def view do
        quote do
          use Phoenix.View,
            root: "lib/appsignal_phoenix_example_web/templates",
            namespace: AppsignalPhoenixExampleWeb

          use Appsignal.Phoenix.View # <- Add this line

          # Import convenience functions from controllers
          import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

          # Include shared imports and aliases for views
          unquote(view_helpers())
        end
      end
      # ...
    end

  """
  defmacro __using__(_) do
    quote do
      require Logger
      Logger.debug("AppSignal.Phoenix.View attached to #{__MODULE__}")

      @before_compile Appsignal.Phoenix.View
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

      defoverridable render: 2

      def render(template, assigns) do
        {root, _pattern, _names} = __templates__()
        path = Path.join(root, template)

        Appsignal.instrument("Render #{path}", fn span ->
          @span.set_attribute(span, "title", path)
          @span.set_attribute(span, "appsignal:category", "render.phoenix_template")
          super(template, assigns)
        end)
      end
    end
  end
end
