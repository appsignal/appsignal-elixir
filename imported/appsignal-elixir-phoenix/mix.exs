defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "2.1.0",
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
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:phoenix_live_view],
        flags: ["-Wunmatched_returns", "-Werror_handling", "-Wunderspecs"]
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
    system_version = System.version()

    mime_dependency =
      if Mix.env() == :test || Mix.env() == :test_no_nif do
        case Version.compare(system_version, "1.10.0") do
          :lt -> [{:mime, "~> 1.0"}]
          _ -> []
        end
      else
        []
      end

    [
      {:appsignal_plug, ">= 2.0.11 and < 3.0.0"},
      {:phoenix, "~> 1.4"},
      {:phoenix_html, "~> 2.11 or ~> 3.0", optional: true},
      {:phoenix_live_view, "~> 0.9", optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:poison, "~> 5.0", only: [:dev, :test], runtime: false}
    ] ++ mime_dependency
  end
end
