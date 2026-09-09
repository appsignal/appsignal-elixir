defmodule Appsignal.Plug.MixProject do
  use Mix.Project

  def project do
    [
      app: :appsignal_plug,
      version: "2.1.3",
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
  #
  # Hex freezes the dependency requirements in this file into the package
  # metadata when the package is published. Applications that install this
  # package resolve their dependencies against those frozen requirements.
  # Some of the requirements below are narrowed on older Elixir and OTP
  # releases, so that this package keeps building on every version in our CI
  # matrix. One of them can also be overridden through an environment
  # variable, which CI uses to test against a specific version of Plug.
  # Publishing with any of those in effect would impose them on every
  # application that installs the package. To catch that, the requirements are
  # computed from a map of versions. That makes it possible to compare the
  # requirements this machine produces with the ones the newest Elixir and OTP
  # releases produce, with no override set.
  @publish_versions %{elixir: "999.0.0", otp: 999, plug: nil}

  defp deps do
    versions = %{
      elixir: System.version(),
      otp: String.to_integer(System.otp_release()),
      plug: System.get_env("_APPSIGNAL_CI_PLUG_VERSION")
    }

    deps = deps(versions)
    verify_publishable!(deps)
    deps
  end

  defp deps(versions) do
    mime_dependency =
      if Mix.env() == :test || Mix.env() == :test_no_nif do
        case Version.compare(versions.elixir, "1.10.0") do
          :lt -> [{:mime, "~> 1.0"}]
          _ -> []
        end
      else
        []
      end

    telemetry_version =
      case versions.otp < 21 do
        true -> "~> 0.4"
        false -> "~> 0.4 or ~> 1.0"
      end

    plug_version =
      versions.plug ||
        case Version.compare(versions.elixir, "1.10.0") do
          :lt -> ">= 1.1.0 and < 1.14.0"
          _ -> ">= 1.18.0"
        end

    credo_version =
      case Version.compare(versions.elixir, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    # Finch 0.22+ requires Elixir 1.15+. On older Elixir versions, cap the
    # version of Finch that's pulled in transitively through the AppSignal
    # package so it can still compile. On newer Elixir versions Finch is left
    # out of the dependency list entirely, so it stays a transitive dependency.
    finch_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> [{:finch, ">= 0.19.0 and < 0.22.0"}]
        _ -> []
      end

    # hpax is a transitive dependency (via finch/mint). Version 1.0.4 requires
    # Elixir ~> 1.15, so pin to the last compatible version on older Elixirs.
    hpax_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> [{:hpax, ">= 1.0.0 and < 1.0.4", override: true}]
        _ -> []
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
      {:plug, plug_version},
      {:appsignal, ">= 2.15.0 and < 3.0.0"},
      {:credo, credo_version, only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:telemetry, telemetry_version}
    ] ++ mime_dependency ++ finch_dependency ++ hpax_dependency ++ mint_dependency
  end

  defp verify_publishable!(deps) do
    publishable_deps = deps(@publish_versions)

    if publishing?() and deps != publishable_deps do
      Mix.raise("""
      This package is being built for Hex, but the dependencies on this \
      machine are not the ones that should be published.

      Some dependency requirements are narrowed on older Elixir and OTP \
      releases, so that this package keeps building there, and one of them \
      can be overridden through an environment variable. Hex freezes the \
      requirements into the package when it is published. Publishing these \
      would impose them on every application that installs the package.

      This machine runs Elixir #{System.version()} on OTP \
      #{System.otp_release()}, and produces:

      #{format_deps(deps -- publishable_deps)}

      The published package must have:

      #{format_deps(publishable_deps -- deps)}

      Publish from the newest Elixir and OTP release, without \
      _APPSIGNAL_CI_PLUG_VERSION set.
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
