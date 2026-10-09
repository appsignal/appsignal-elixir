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
  @version "2.18.1"

  def project do
    [
      app: :appsignal,
      version: @version,
      name: "AppSignal",
      description: description(),
      package: package(),
      homepage_url: "https://appsignal.com",
      test_paths: ["test/appsignal", "test/mix"],
      elixir: "~> 1.12",
      compilers: compilers(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps() ++ dependency_set_deps(),
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
    ] ++ dependency_set_paths()
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

  defp elixirc_paths(env) do
    case test?(env) do
      true ->
        ["lib", "test/support"]

      false ->
        ["lib"]
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
  # matrix. Publishing with any of those in effect would impose them on every
  # application that installs the package. To catch that, the requirements are
  # computed from a map of versions. That makes it possible to compare the
  # requirements this machine produces with the ones the newest Elixir and OTP
  # releases produce.
  @publish_versions %{env: :prod, elixir: "999.0.0", otp: 999, set: nil}

  defp versions do
    %{
      env: Mix.env(),
      elixir: System.version(),
      otp: String.to_integer(System.otp_release()),
      set: dependency_set()
    }
  end

  defp deps do
    deps = deps(versions())
    verify_publishable!(deps)
    deps
  end

  defp deps(versions) do
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

    mint_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt ->
          [{:mint, "1.9.2"}]

        _ ->
          []
      end

    plug_version =
      case Version.compare(versions.elixir, "1.14.0") do
        :lt ->
          "~> 1.18 and < 1.19.0"

        _ ->
          # plug 1.20.0 requires Elixir ~> 1.15, so cap it on 1.14.
          case Version.compare(versions.elixir, "1.15.0") do
            :lt -> "~> 1.18 and < 1.20.0"
            _ -> "~> 1.18"
          end
      end

    # Phoenix 1.8 requires Elixir 1.15. Hex does not take the Elixir version
    # into account when it resolves dependencies, so cap Phoenix below 1.8 on
    # older Elixir versions.
    phoenix_version =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> "~> 1.7 and < 1.8.0"
        _ -> "~> 1.7"
      end

    phoenix_live_view_version =
      case Version.compare(versions.elixir, "1.14.0") do
        :lt -> ">= 0.17.12 and < 1.1.0"
        _ -> ">= 0.17.12 and < 2.0.0"
      end

    # phoenix_template is a transitive dependency. Version 1.1.0 requires
    # Elixir 1.16 and uses a bitstring pattern that older Elixirs cannot
    # compile, so pin to the last version that does compile there.
    phoenix_template_dependency =
      case Version.compare(versions.elixir, "1.15.0") do
        :lt -> [{:phoenix_template, ">= 1.0.0 and < 1.1.0", optional: true}]
        _ -> []
      end

    integrations = integrations(versions)

    plug_dependencies =
      case :plug in integrations do
        true -> [{:plug, plug_version, optional: true}]
        false -> []
      end

    phoenix_dependencies =
      case :phoenix in integrations do
        true ->
          [
            {:phoenix, phoenix_version, optional: true},
            {:phoenix_live_view, phoenix_live_view_version, optional: true}
          ] ++ phoenix_template_dependency

        false ->
          []
      end

    httpoison_dependencies =
      case :httpoison in integrations do
        true -> [{:httpoison, httpoison_version, optional: true}]
        false -> []
      end

    integration_dependencies = plug_dependencies ++ phoenix_dependencies ++ httpoison_dependencies

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
      {:decorator, "~> 1.2.3 or ~> 1.3"},
      {:ex_doc, "~> 0.12", only: :dev, runtime: false},
      {:credo, credo_version, only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:telemetry, telemetry_version}
    ] ++
      logger_backends_dependency ++
      hpax_dependency ++ mint_dependency ++ integration_dependencies
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
      would impose them on every application that installs the package.

      This machine runs Elixir #{System.version()} on OTP \
      #{System.otp_release()}, and produces:

      #{format_deps(deps -- publishable_deps)}

      The published package must have:

      #{format_deps(publishable_deps -- deps)}

      Publish from the newest Elixir and OTP release, without \
      _APPSIGNAL_TEST_DEPS set.
      """)
    end
  end

  # Dependency sets declare these libraries themselves, at the versions they
  # test, so the test environments leave out the package's requirements.
  defp integrations(%{env: env}) when env in [:test, :test_no_nif], do: []
  defp integrations(%{set: set}) when is_binary(set), do: []
  defp integrations(_versions), do: [:plug, :phoenix, :httpoison]

  # A dependency set is a file in test/deps listing the third-party libraries
  # the test suite runs against, chosen by name with _APPSIGNAL_TEST_DEPS.
  # Its dependencies are test-only, so they never reach the published
  # package. Each set has its own lockfile and build directory, so switching
  # between sets does not resolve or compile another set's dependencies again.
  defp dependency_set, do: ci_version("_APPSIGNAL_TEST_DEPS")

  defp dependency_set_deps do
    case dependency_set() do
      nil ->
        []

      name ->
        path = "test/deps/#{name}.exs"

        unless File.exists?(path) do
          sets = "test/deps/*.exs" |> Path.wildcard() |> Enum.map(&Path.basename(&1, ".exs"))
          Mix.raise("No dependency set named #{name}. Available: #{Enum.join(sets, ", ")}")
        end

        {deps, _binding} = Code.eval_file(path)
        Enum.map(deps, &test_only/1)
    end
  end

  defp test_only({app, requirement}), do: test_only({app, requirement, []})

  defp test_only({app, requirement, opts}) do
    {app, requirement, Keyword.put(opts, :only, [:test, :test_no_nif])}
  end

  defp dependency_set_paths do
    case dependency_set() do
      nil ->
        []

      name ->
        [
          lockfile: "deps/sets/#{name}/mix.lock",
          deps_path: "deps/sets/#{name}",
          build_path: "_build/sets/#{name}"
        ]
    end
  end

  # GitHub Actions sets a matrix variable that a job does not define to an
  # empty string.
  defp ci_version(name) do
    case System.get_env(name) do
      nil -> nil
      "" -> nil
      version -> version
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
