# An application that depends on this package, as the applications that
# install it do. Mix compiles a dependency with only its own dependencies on
# the code path, so the package compiles without the libraries in the
# dependency set, and the tests and their support files compile with them.
# Run it from the root of this repository, with script/test, or with:
#
#     MIX_EXS=test/app/mix.exs _APPSIGNAL_TEST_DEPS=phoenix mix test
defmodule AppsignalTest.App.MixProject do
  use Mix.Project

  def project do
    set = System.get_env("_APPSIGNAL_TEST_DEPS", "none")

    # Read by the package's mix.exs, which leaves out its test support and
    # dependency set when built as a dependency.
    System.put_env("_APPSIGNAL_AS_DEPENDENCY", "true")

    [
      app: :appsignal_test_app,
      version: "0.0.0",
      elixir: "~> 1.12",
      elixirc_paths: ["test/support"],
      test_paths: ["test/appsignal", "test/mix"],
      deps: [{:appsignal, path: ".", env: :test} | dependency_set(set)],
      lockfile: "deps/app/#{set}/mix.lock",
      deps_path: "deps/app/#{set}",
      build_path: "_build/app/#{set}"
    ]
  end

  def application, do: [extra_applications: [:logger, :inets]]

  defp dependency_set("none"), do: []

  defp dependency_set(set) do
    {deps, _binding} = Code.eval_file("test/deps/#{set}.exs")
    deps
  end
end
