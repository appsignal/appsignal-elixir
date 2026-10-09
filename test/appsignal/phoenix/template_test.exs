if Appsignal.Dependencies.present?(:phoenix) do
  defmodule Appsignal.Phoenix.TemplateTest do
    use AppsignalTest.IntegrationCase
    alias AppsignalTest.Phoenix.{Templates, UninstrumentedTemplates}

    @formats [eex: :index_html_eex, exs: :index_html_exs]

    describe "rendering a template, compared with Phoenix's engines" do
      for {format, function} <- @formats do
        test "renders a #{format} template as Phoenix's engine does" do
          assert Templates.unquote(function)(%{}) ==
                   UninstrumentedTemplates.unquote(function)(%{})
        end
      end
    end

    describe "the span recorded for a render" do
      for {format, function} <- @formats do
        test "is a child span named after the template's path, for a #{format} template" do
          Appsignal.instrument("parent", fn -> Templates.unquote(function)(%{}) end)

          path = "test/support/phoenix/index.html.#{unquote(format)}"
          assert [parent, render] = spans()
          assert render["name"] == "Render #{path}"
          assert render["parent_span_id"] == parent["span_id"]
          assert category(render) == "render.phoenix_template"
          assert render["attributes"]["title"] == path
        end

        test "is a root span outside an instrumented function, for a #{format} template" do
          Templates.unquote(function)(%{})

          assert [render] = spans()
          assert render["parent_span_id"] == ""
          assert render["namespace"] == "background_job"
        end
      end
    end
  end

  if Appsignal.Dependencies.present?(:phoenix_view) do
    defmodule Appsignal.Phoenix.ViewTest do
      use AppsignalTest.IntegrationCase
      alias AppsignalTest.Phoenix.{LegacyView, UninstrumentedLegacyView}

      describe "rendering a view, compared with a view without Appsignal.Phoenix.View" do
        test "renders as the view without Appsignal.Phoenix.View does" do
          assert Phoenix.View.render_to_string(LegacyView, "index.html", %{}) ==
                   Phoenix.View.render_to_string(UninstrumentedLegacyView, "index.html", %{})
        end
      end

      describe "the span recorded for a render" do
        test "is a child span named after the template's path" do
          Appsignal.instrument("parent", fn ->
            Phoenix.View.render_to_string(LegacyView, "index.html", %{})
          end)

          assert [parent, render] = spans()
          assert render["name"] == "Render test/support/phoenix/legacy/index.html"
          assert render["parent_span_id"] == parent["span_id"]
          assert category(render) == "render.phoenix_template"
          assert render["attributes"]["title"] == "test/support/phoenix/legacy/index.html"
        end
      end

      describe "renders that record no span" do
        test "outside an instrumented function" do
          assert Phoenix.View.render_to_string(LegacyView, "index.html", %{}) =~ "Welcome"
          assert spans() == []
        end
      end
    end
  end
end
