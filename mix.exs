unless Code.ensure_loaded?(Appsignal.Agent) do
  {_, _} = Code.eval_file("agent.ex")
end

defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  def run(_args) do
    {_, _} = Code.eval_file("mix_helpers.exs")

    case Mix.Appsignal.Helper.verify_system_architecture() do
      {:ok, arch} ->
        :ok = Mix.Appsignal.Helper.ensure_downloaded(arch)
        :ok = Mix.Appsignal.Helper.compile
      {:error, {:unsupported, arch}} ->
        Mix.Shell.IO.error(
          "Unsupported target platform #{arch}, AppSignal integration " <>
          "disabled!\nPlease check " <>
          "http://docs.appsignal.com/support/operating-systems.html"
        )
        :ok
    end
  end
end

defmodule Appsignal.Mixfile do
  use Mix.Project
  @agent_version Appsignal.Agent.version

  def project do
    [app: :appsignal,
     version: "1.2.2",
     name: "AppSignal",
     description: description(),
     package: package(),
     source_url: "https://github.com/appsignal/appsignal-elixir",
     homepage_url: "https://appsignal.com",
     test_paths: test_paths(Mix.env),
     elixir: "~> 1.0",
     compilers: compilers(Mix.env),
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps(),
     docs: [logo: "logo.png"],
     agent_version: @agent_version
    ]
  end

  defp description do
    "Collects error and performance data from your Elixir applications and sends it to AppSignal"
  end

  defp package do
    %{files: ["lib", "c_src/*.[ch]", "mix.exs", "mix_helpers.exs",
              "*.md", "LICENSE", "Makefile", "agent.ex"],
      maintainers: ["Arjan Scherpenisse", "Jeff Kreeftmeijer", "Tom de Bruijn"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir"}}
  end

  def application do
    [mod: {Appsignal, []},
     applications: [:logger, :decorator, :httpoison]]
  end

  defp compilers(:test_phoenix), do: [:phoenix] ++ compilers(:prod)
  defp compilers(_), do: [:appsignal] ++ Mix.compilers

  defp test_paths(:test_phoenix), do: ["test/appsignal", "test/mix", "test/phoenix"]
  defp test_paths(_), do: ["test/appsignal", "test/mix"]

  defp elixirc_paths(env) do
    case test?(env) do
      true -> ["lib", "test/support"]
      false -> ["lib"]
    end
  end

  defp test?(:test), do: true
  defp test?(:test_phoenix), do: true
  defp test?(:test_no_nif), do: true
  defp test?(_), do: false

  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:poison, ">= 1.3.0"},
      {:decorator, "~> 1.0"},
      {:plug, ">= 1.1.0", optional: true},
      {:phoenix, ">= 1.2.0", optional: true, only: [:prod, :test_phoenix, :dev]},
      {:mock, "~> 0.2.1", only: [:test, :test_phoenix, :test_no_nif]},
      {:bypass, "~> 0.5", only: [:test, :test_phoenix, :test_no_nif]},
      {:ex_doc, "~> 0.12", only: :dev, runtime: false}
    ]
  end
end
