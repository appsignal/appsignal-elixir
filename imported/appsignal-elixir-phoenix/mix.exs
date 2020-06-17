defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "2.0.0-alpha.2",
      description:
        "AppSignal's Phoenix instrumentation instruments calls to Phoenix applications to gain performance insights and error reporting",
      package: %{
        maintainers: ["Jeff Kreeftmeijer"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir-phoenix"}
      },
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: compilers(Mix.env()),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Appsignal.Phoenix.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp compilers(:test), do: [:phoenix] ++ Mix.compilers()
  defp compilers(_), do: Mix.compilers()

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:appsignal_plug, "~> 2.0.0-alpha.1"},
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.11", only: :test},
      {:telemetry, "~> 0.4"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
