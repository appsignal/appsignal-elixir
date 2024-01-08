defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "2.3.4",
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
    otp_version = System.otp_release()

    hackney_version =
      case otp_version >= "21" do
        true -> "~> 1.6"
        false -> "1.18.1"
      end

    mime_and_plug_dependencies =
      if Mix.env() == :test || Mix.env() == :test_no_nif do
        case Version.compare(system_version, "1.10.0") do
          :lt -> [{:plug, "~> 1.13.0"}, {:mime, "~> 1.0"}]
          _ -> []
        end
      else
        []
      end

    phoenix_live_view_version =
      case {otp_version < "21", Version.compare(system_version, "1.12.0")} do
        {true, _} -> ">= 0.9.0 and < 0.17.4"
        {_, :lt} -> ">= 0.9.0 and < 0.18.0"
        {_, _} -> "~> 0.9"
      end

    telemetry_version =
      case otp_version < "21" do
        true -> "~> 0.4"
        false -> "~> 0.4 or ~> 1.0"
      end

    [
      {:appsignal, ">= 2.7.6 and < 3.0.0"},
      {:appsignal_plug, ">= 2.0.15 and < 3.0.0"},
      {:phoenix, System.get_env("PHOENIX_VERSION", "~> 1.4")},
      {:phoenix_html, "~> 2.11 or ~> 3.0 or ~> 4.0", optional: true},
      {:phoenix_live_view, phoenix_live_view_version, optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:poison, "~> 5.0", only: [:dev, :test], runtime: false},
      {:telemetry, telemetry_version},
      {:hackney, hackney_version}
    ] ++ mime_and_plug_dependencies
  end
end
