if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.TemplateInstrumenter do
    @moduledoc """
    Instrument Phoenix template engines

    As documented in the [phoenix
    guidelines](http://docs.appsignal.com/elixir/integrations/phoenix.html),
    The AppSignal Elixir library comes with default template engines to
    instrument renders to `.eex` and `.exs` template files.

    When you use another template engine in your Phoenix project, you
    can create a module which wraps the template renderer to also
    instrument those template files.

    To instrument the
    [phoenix_markdown](https://github.com/boydm/phoenix_markdown)
    library, you would create the following renderer engine module:

    ```
    defmodule MyApp.InstrumentedMarkdownEngine do
      use Appsignal.Phoenix.TemplateInstrumenter, engine: PhoenixMarkdown.Engine
    endmodule
    ```

    And then register the `.md` extension as a template as follows:

    ```
    config :phoenix, :template_engines,
      md: MyApp.InstrumentedMarkdownEngine
    ```

    """

    @doc false
    defmacro __using__(opts) do
      quote do
        @behaviour Phoenix.Template.Engine

        def compile(path, name) do
          expr = unquote(opts[:engine]).compile(path, name)
          quote do
            Appsignal.Instrumentation.Helpers.instrument(
              self(),
              "render.phoenix_template",
              unquote(path),
              fn() -> unquote(expr) end
            )
          end
        end
      end
    end
  end
end
