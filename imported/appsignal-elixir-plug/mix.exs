defmodule Appsignal.Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_plug,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, ">= 1.1.0"},
      {:appsignal, github: "appsignal/appsignal-elixir", branch: "tracing"},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
