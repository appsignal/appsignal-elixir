defmodule Appsignal.Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_plug,
      version: "2.1.1",
      description:
        "AppSignal's Plug instrumentation instruments calls to Plug applications to gain performance insights and error reporting",
      package: %{
        maintainers: ["Jeff Kreeftmeijer"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir-plug"}
      },
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: ["-Wunmatched_returns", "-Werror_handling", "-Wunderspecs"]
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
    system_version = System.version()
    otp_version = System.otp_release()

    mime_dependency =
      if Mix.env() == :test || Mix.env() == :test_no_nif do
        case Version.compare(system_version, "1.10.0") do
          :lt -> [{:mime, "~> 1.0"}]
          _ -> []
        end
      else
        []
      end

    telemetry_version =
      case otp_version < "21" do
        true -> "~> 0.4"
        false -> "~> 0.4 or ~> 1.0"
      end

    plug_version =
      case Version.compare(system_version, "1.10.0") do
        :lt -> ">= 1.1.0 and < 1.14.0"
        _ -> ">= 1.1.0"
      end

    credo_version =
      case Version.compare(system_version, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    [
      {:plug, plug_version},
      {:appsignal, ">= 2.15.0 and < 3.0.0"},
      {:credo, credo_version, only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:telemetry, telemetry_version}
    ] ++ mime_dependency
  end
end
