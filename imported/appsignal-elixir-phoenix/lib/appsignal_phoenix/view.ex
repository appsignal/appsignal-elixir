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
      Appsignal.IntegrationLogger.debug("AppSignal.Phoenix.View attached to #{__MODULE__}")

      @before_compile Appsignal.Phoenix.View
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      if Module.defines?(__MODULE__, {:__templates__, 0}) &&
           Module.defines?(__MODULE__, {:render, 2}) do
        @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
        @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)

        defoverridable render: 2

        def render(template, assigns) when is_binary(template) do
          {root, _pattern, _names} = __templates__()
          path = Path.join(root, template)

          do_render(@tracer.current_span(), path, fn ->
            super(template, assigns)
          end)
        end

        def render(template, assigns) do
          super(template, assigns)
        end

        defp do_render(%Appsignal.Span{} = span, path, fun) do
          Appsignal.instrument("Render #{path}", fn span ->
            _ =
              span
              |> @span.set_attribute("title", path)
              |> @span.set_attribute("appsignal:category", "render.phoenix_template")

            fun.()
          end)
        end

        defp do_render(_span, _path, fun) do
          fun.()
        end
      else
        Logger.warning("""
        AppSignal.Phoenix.View NOT attached to #{__MODULE__}

        Template rendering instrumentation is now set up automatically, so using
        Appsignal.Phoenix.View in your app's web module is no longer needed.
        """)
      end
    end
  end
end
