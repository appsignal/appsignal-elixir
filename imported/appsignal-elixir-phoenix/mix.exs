defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: compilers(Mix.env())
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
      {:appsignal_plug, github: "appsignal/appsignal-elixir-plug"},
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.11", only: :test},
      {:telemetry, "~> 0.4"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
