# Before Elixir 1.15, Mix compiles a dependency with every dependency
# compiled before it on the code path, so the libraries can be visible.
if System.get_env("_APPSIGNAL_AS_DEPENDENCY") == "true" and
     Version.match?(System.version(), ">= 1.15.0") do
  defmodule AppsignalTest.CompileProbeTest do
    use ExUnit.Case, async: true

    test "the package compiles without the libraries from the dependency sets" do
      assert AppsignalTest.CompileProbe.visible() == []
    end
  end
end
