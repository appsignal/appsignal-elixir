# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity

defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  def run(_args) do
    {_, _} = Code.eval_file("mix_helpers.exs")
    Mix.Appsignal.Helper.install()
    {:ok, []}
  end
end

defmodule Appsignal.Mixfile do
  use Mix.Project

  @source_url "https://github.com/appsignal/appsignal-elixir"
  @version "2.12.3"

  def project do
    [
      app: :appsignal,
      version: @version,
      name: "AppSignal",
      description: description(),
      package: package(),
      homepage_url: "https://appsignal.com",
      test_paths: test_paths(Mix.env()),
      elixir: "~> 1.9",
      compilers: compilers(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: [
        main: "readme",
        logo: "logo.png",
        source_ref: "v#{@version}",
        source_url: @source_url,
        extras: ["README.md", "CHANGELOG.md"]
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ]
    ]
  end

  defp description do
    "Collects error and performance data from your Elixir applications and sends it to AppSignal"
  end

  defp package do
    %{
      files: [
        "lib",
        "c_src/*.[ch]",
        "mix.exs",
        "mix_helpers.exs",
        "*.md",
        "LICENSE",
        "Makefile",
        "agent.exs",
        "priv/cacert.pem",
        "README.md",
        "CHANGELOG.md"
      ],
      maintainers: ["Jeff Kreeftmeijer", "Tom de Bruijn"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "GitHub" => @source_url
      }
    }
  end

  def application do
    [
      extra_applications: [
        :logger,
        :runtime_tools
      ],
      mod: {Appsignal, []}
    ]
  end

  defp compilers(_), do: [:appsignal] ++ Mix.compilers()

  defp test_paths(_), do: ["test/appsignal", "test/mix"]

  defp elixirc_paths(env) do
    case test?(env) do
      true -> ["lib", "test/support"]
      false -> ["lib"]
    end
  end

  defp test?(:test), do: true
  defp test?(:test_no_nif), do: true
  defp test?(:bench), do: true
  defp test?(_), do: false

  defp deps do
    system_version = System.version()
    otp_version = System.otp_release()

    hackney_version =
      case otp_version >= "21" do
        true -> "~> 1.6"
        false -> "1.18.1"
      end

    decorator_version =
      case Version.compare(system_version, "1.5.0") do
        :lt -> "~> 1.2.3"
        _ -> "~> 1.2.3 or ~> 1.3"
      end

    telemetry_version =
      case otp_version < "21" do
        true -> "~> 0.4"
        false -> "~> 0.4 or ~> 1.0"
      end

    mime_dependency =
      case Version.compare(system_version, "1.10.0") do
        :lt -> [{:mime, "~> 1.0", only: [:test, :test_no_nif]}]
        _ -> []
      end

    plug_version =
      case Version.compare(system_version, "1.10.0") do
        :lt -> "~> 1.13.6"
        _ -> "~> 1.14"
      end

    credo_version =
      case Version.compare(system_version, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    [
      {:decimal, "~> 2.0"},
      {:benchee, "~> 1.0", only: :bench},
      {:hackney, hackney_version},
      {:jason, "~> 1.0"},
      {:decorator, decorator_version},
      {:plug, plug_version, only: [:test, :test_no_nif]},
      {:plug_cowboy, "~> 1.0", only: [:test, :test_no_nif]},
      {:bypass, "~> 0.6.0", only: [:test, :test_no_nif]},
      {:ex_doc, "~> 0.12", only: :dev, runtime: false},
      {:credo, credo_version, only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:telemetry, telemetry_version}
    ] ++ mime_dependency
  end
end
