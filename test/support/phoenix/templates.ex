if Appsignal.Dependencies.present?(:phoenix) do
  # The same templates, compiled with AppSignal's template engines and with
  # Phoenix's own.
  for {module, engines} <- [
        {AppsignalTest.Phoenix.Templates,
         %{eex: Appsignal.Phoenix.Template.EExEngine, exs: Appsignal.Phoenix.Template.ExsEngine}},
        {AppsignalTest.Phoenix.UninstrumentedTemplates,
         %{eex: Phoenix.Template.EExEngine, exs: Phoenix.Template.ExsEngine}}
      ] do
    defmodule module do
      @moduledoc false
      require Phoenix.Template

      Phoenix.Template.compile_all(
        &(&1 |> Path.basename() |> String.replace(".", "_")),
        "test/support/phoenix",
        "index.html",
        engines
      )
    end
  end

  if Appsignal.Dependencies.present?(:phoenix_view) do
    # Views as applications wrote them before Phoenix 1.7, with
    # `Appsignal.Phoenix.View` and without it.
    for {module, instrumented?} <- [
          {AppsignalTest.Phoenix.LegacyView, true},
          {AppsignalTest.Phoenix.UninstrumentedLegacyView, false}
        ] do
      defmodule module do
        @moduledoc false
        use Phoenix.View, root: "test/support/phoenix", path: "legacy"

        if instrumented? do
          use Appsignal.Phoenix.View
        end
      end
    end
  end
end
