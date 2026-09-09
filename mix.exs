# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity

defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  @requirements "loadpaths"

  def run(_args) do
    # Remove all :appsignal environment overrides before evaluating mix_helpers.exs
    # so that Application.compile_env/3 resolves to production defaults (real modules).
    # This prevents fake test modules from being injected into the extension install task.
    # The :config key is excluded as it holds user-facing AppSignal configuration.
    saved = Application.get_all_env(:appsignal)

    Enum.each(saved, fn
      {:config, _} -> :ok
      {key, _} -> Application.delete_env(:appsignal, key)
    end)

    {_, _} = Code.eval_file("mix_helpers.exs")
    Mix.Appsignal.Helper.install()

    Enum.each(saved, fn {key, val} -> Application.put_env(:appsignal, key, val) end)

    {:ok, []}
  end
end

defmodule Appsignal.Mixfile do
  use Mix.Project

  @source_url "https://github.com/appsignal/appsignal-elixir"
  @version "2.17.4"

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
        plt_add_apps: [:mix],
        ignore_warnings: ".dialyzer_ignore.exs"
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

  # Hex freezes the dependency requirements in this file into the package
  # metadata when the package is published. Applications that install this
  # package resolve their dependencies against those frozen requirements.
  # Some of the requirements below are narrowed on older Elixir and OTP
  # releases, so that this package keeps building on every version in our CI
  # matrix. Publishing from one of those releases would impose the narrower
  # requirements on every application that installs the package. To catch
  # that, the requirements are computed from a map of versions. That makes it
  # possible to compare the requirements this machine produces with the ones
  # the newest Elixir and OTP releases produce.
  @publish_versions %{elixir: "999.0.0", otp: 999}

  defp deps do
    versions = %{
      elixir: System.version(),
      otp: String.to_integer(System.otp_release())
    }

    deps = deps(versions)
    verify_publishable!(deps)
    deps
  end

  defp deps(versions) do
    decorator_version =
      case Version.compare(versions.elixir, "1.5.0") do
        :lt -> "~> 1.2.3"
        _ -> "~> 1.2.3 or ~> 1.3"
      end

    finch_version =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> ">= 0.19.0 and < 0.22.0"
        _ -> "~> 0.19"
      end

    telemetry_version =
      case versions.otp < 21 do
        true -> "~> 0.4"
        false -> "~> 0.4 or ~> 1.0"
      end

    # httpoison 3.0 depends on hackney 4.0, which pulls in quic and requires
    # OTP 26 or later. Cap httpoison at 2.x on older OTP releases.
    httpoison_version =
      case versions.otp < 26 do
        true -> "~> 2.0"
        false -> "~> 2.0 or ~> 3.0"
      end

    mime_dependency =
      case Version.compare(versions.elixir, "1.10.0") do
        :lt -> [{:mime, "~> 1.0", only: [:test, :test_no_nif]}]
        _ -> []
      end

    mint_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt ->
          [{:mint, "1.9.2"}]

        _ ->
          []
      end

    plug_version =
      case Version.compare(versions.elixir, "1.10.0") do
        :lt ->
          "~> 1.13.6"

        _ ->
          case Version.compare(versions.elixir, "1.14.0") do
            :lt ->
              "~> 1.14 and < 1.19.0"

            _ ->
              # plug 1.20.0 requires Elixir ~> 1.15, so cap it on 1.14.
              case Version.compare(versions.elixir, "1.15.0") do
                :lt -> "~> 1.14 and < 1.20.0"
                _ -> "~> 1.14"
              end
          end
      end

    credo_version =
      case Version.compare(versions.elixir, "1.13.0") do
        :lt -> "1.7.6"
        _ -> "~> 1.7"
      end

    logger_backends_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> []
        _ -> [{:logger_backends, "~> 1.0"}]
      end

    # hpax is a transitive dependency (via finch/mint). Version 1.0.4 requires
    # Elixir ~> 1.15, so pin to the last compatible version on older Elixirs.
    hpax_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> [{:hpax, ">= 1.0.0 and < 1.0.4", override: true}]
        _ -> []
      end

    [
      {:castore, "~> 1.0"},
      {:certifi, "~> 2.14"},
      {:decimal, "~> 2.0 or ~> 3.1"},
      {:benchee, "~> 1.0", only: :bench},
      {:finch, finch_version},
      {:jason, "~> 1.0"},
      {:decorator, decorator_version},
      {:plug, plug_version, only: [:test, :test_no_nif]},
      {:plug_cowboy, "~> 1.0", only: [:test, :test_no_nif]},
      {:bypass, "~> 0.6.0", only: [:test, :test_no_nif]},
      {:ex_doc, "~> 0.12", only: :dev, runtime: false},
      {:credo, credo_version, only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:telemetry, telemetry_version},
      {:httpoison, httpoison_version, optional: true}
    ] ++ mime_dependency ++ logger_backends_dependency ++ hpax_dependency ++ mint_dependency
  end

  defp verify_publishable!(deps) do
    publishable_deps = deps(@publish_versions)

    if publishing?() and deps != publishable_deps do
      Mix.raise("""
      This package is being built for Hex, but the dependencies on this \
      machine are not the ones that should be published.

      Some dependency requirements are narrowed on older Elixir and OTP \
      releases, so that this package keeps building there. Hex freezes the \
      requirements into the package when it is published. Publishing these \
      would impose the narrower requirements on every application that \
      installs the package.

      This machine runs Elixir #{System.version()} on OTP \
      #{System.otp_release()}, and produces:

      #{format_deps(deps -- publishable_deps)}

      The published package must have:

      #{format_deps(publishable_deps -- deps)}

      Publish from the newest Elixir and OTP release instead.
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
