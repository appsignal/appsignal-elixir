defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "2.7.0",
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    system_version = System.version()

    phoenix_live_view_version =
      case Version.compare(system_version, "1.12.0") do
        :lt -> ">= 0.9.0 and < 0.18.0"
        _ -> "~> 0.9 or ~> 1.0"
      end

    credo_version =
      case Version.compare(system_version, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    [
      {:appsignal, ">= 2.15.0 and < 3.0.0"},
      {:appsignal_plug, ">= 2.1.0 and < 3.0.0"},
      {:phoenix, System.get_env("PHOENIX_VERSION", "~> 1.4")},
      {:phoenix_html, "~> 2.11 or ~> 3.0 or ~> 4.0", optional: true},
      {:phoenix_live_view, phoenix_live_view_version, optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:credo, credo_version, only: [:dev, :test], runtime: false},
      {:telemetry, "~> 0.4 or ~> 1.0"}
    ]
  end
end
