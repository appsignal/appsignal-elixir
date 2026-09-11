defmodule Appsignal.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_phoenix,
      version: "2.8.2",
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
  #
  # Hex freezes the dependency requirements in this file into the package
  # metadata when the package is published. Applications that install this
  # package resolve their dependencies against those frozen requirements.
  # Some of the requirements below are narrowed on older Elixir releases, so
  # that this package keeps building on every version in our CI matrix. Two of
  # them can also be overridden through environment variables, which CI uses
  # to test against specific versions of Phoenix and Plug. Publishing with any
  # of those in effect would impose them on every application that installs
  # the package. To catch that, the requirements are computed from a map of
  # versions. That makes it possible to compare the requirements this machine
  # produces with the ones the newest Elixir release produces, with no
  # overrides set.
  @publish_versions %{elixir: "999.0.0", phoenix: nil, plug: nil}

  defp deps do
    versions = %{
      elixir: System.version(),
      phoenix: System.get_env("_APPSIGNAL_CI_PHOENIX_VERSION"),
      plug: System.get_env("_APPSIGNAL_CI_PLUG_VERSION")
    }

    deps = deps(versions)
    verify_publishable!(deps)
    deps
  end

  defp deps(versions) do
    phoenix_live_view_version =
      case Version.compare(versions.elixir, "1.12.0") do
        :lt ->
          ">= 0.9.0 and < 0.18.0"

        _ ->
          case Version.compare(versions.elixir, "1.14.0") do
            :lt -> "~> 0.9 or ~> 1.0.0"
            _ -> "~> 0.9 or ~> 1.0"
          end
      end

    credo_version =
      case Version.compare(versions.elixir, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    phoenix_version = versions.phoenix || "~> 1.7"

    plug_override =
      case versions.plug do
        nil -> []
        "" -> []
        version -> [{:plug, version, override: true}]
      end

    # Finch 0.22 requires Elixir 1.15 or newer, and so does HPAX 1.0.4, which
    # Finch pulls in through Mint. The lock file is not checked in, so every
    # build resolves the newest version of both, and neither compiles on older
    # Elixir versions. Cap them there.
    #
    # Both are transitive dependencies through the AppSignal package. On newer
    # Elixir versions they are left out of the dependency list entirely, so
    # these caps are never imposed on the published package.
    finch_dependencies =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt ->
          [
            {:finch, ">= 0.19.0 and < 0.22.0"},
            {:hpax, ">= 1.0.0 and < 1.0.4", override: true}
          ]

        _ ->
          []
      end

    # mint is a transitive dependency (via finch). Version 1.10.0 uses a
    # bitstring pattern that older Elixirs cannot compile, so pin to the last
    # version that does compile there.
    mint_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> [{:mint, "1.9.2"}]
        _ -> []
      end

    [
      {:appsignal, ">= 2.15.0 and < 3.0.0"},
      {:appsignal_plug, ">= 2.1.0 and < 3.0.0"},
      {:phoenix, phoenix_version},
      {:phoenix_html, "~> 2.11 or ~> 3.0 or ~> 4.0", optional: true},
      {:phoenix_live_view, phoenix_live_view_version, optional: true},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:credo, credo_version, only: [:dev, :test], runtime: false},
      {:telemetry, "~> 0.4 or ~> 1.0"}
    ] ++ plug_override ++ finch_dependencies ++ mint_dependency
  end

  defp verify_publishable!(deps) do
    publishable_deps = deps(@publish_versions)

    if publishing?() and deps != publishable_deps do
      Mix.raise("""
      This package is being built for Hex, but the dependencies on this \
      machine are not the ones that should be published.

      Some dependency requirements are narrowed on older Elixir releases, so \
      that this package keeps building there, and two of them can be \
      overridden through environment variables. Hex freezes the requirements \
      into the package when it is published. Publishing these would impose \
      them on every application that installs the package.

      This machine runs Elixir #{System.version()}, and produces:

      #{format_deps(deps -- publishable_deps)}

      The published package must have:

      #{format_deps(publishable_deps -- deps)}

      Publish from the newest Elixir release, without \
      _APPSIGNAL_CI_PHOENIX_VERSION or _APPSIGNAL_CI_PLUG_VERSION set.
      """)
    end
  end

  # Mix passes the name of the task it runs and that task's arguments as the
  # command line arguments of the Elixir process. That makes it possible to
  # tell, while this file is being evaluated, that it is being evaluated to
  # build a package for Hex. The task name is not always the first argument,
  # because `mix do` runs more than one task in a single invocation, so look
  # for it anywhere in the arguments.
  defp publishing? do
    Enum.any?(["hex.build", "hex.publish"], &(&1 in System.argv()))
  end

  defp format_deps([]), do: "  (none)"
  defp format_deps(deps), do: Enum.map_join(deps, "\n", &"  #{inspect(&1)}")
end
