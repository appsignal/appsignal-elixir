defmodule Mix.Tasks.Compile.Appsignal do
  use Mix.Task

  def run(_args) do
    {_, _} = Code.eval_file("mix_helpers.exs")
    :ok = Mix.Appsignal.Helper.ensure_downloaded
    :ok = Mix.Appsignal.Helper.compile
  end
end


defmodule Appsignal.Mixfile do
  use Mix.Project

  def project do
    [app: :appsignal,
     version: "0.0.1",
     name: "AppSignal",
     description: description(),
     package: package(),
     source_url: "https://github.com/appsignal/appsignal-elixir",
     homepage_url: "https://appsignal.com",
     elixir: "~> 1.0",
     compilers: [:appsignal] ++ Mix.compilers,
     deps: deps,
     docs: [logo: "logo.png",
            extras: ["README.md", "Roadmap.md"]]
    ]
  end

  defp description do
    "Collects error and performance data from your Elixir applications and sends it to AppSignal"
  end

  defp package do
    %{files: ["lib", "c_src/*.[ch]", "mix.exs", "mix_helpers.exs",
              "README.md", "Roadmap.md", "LICENSE", "Makefile"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/appsignal/appsignal-elixir"}}
  end

  def application do
    [mod: {Appsignal, []},
     applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 2.1"},

      {:plug, "~> 1.0", only: [:test, :dev]},
      {:phoenix, "~> 1.2.0", only: [:test, :dev]},

      {:ex_doc, "~> 0.12", only: :dev}
    ]
  end
end
