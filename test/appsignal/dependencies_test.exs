defmodule Appsignal.DependenciesTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import AppsignalTest.Utils
  alias Appsignal.{Config, Dependencies}

  defp load_package(app, vsn) do
    :ok =
      :application.load(
        {:application, app,
         [description: ~c"#{app}", vsn: ~c"#{vsn}", modules: [], registered: [], applications: []]}
      )

    on_exit(fn -> Application.unload(app) end)
  end

  describe "conflicts/0" do
    test "without other AppSignal packages" do
      assert Dependencies.conflicts() == :ok
    end

    test "with appsignal_phoenix 2.x installed" do
      load_package(:appsignal_phoenix, "2.8.2")

      assert Dependencies.conflicts() ==
               {:error, %{packages: [{:appsignal_phoenix, "2.8.2"}], modules: []}}
    end

    test "with appsignal_plug 2.x installed" do
      load_package(:appsignal_plug, "2.1.3")

      assert Dependencies.conflicts() ==
               {:error, %{packages: [{:appsignal_plug, "2.1.3"}], modules: []}}
    end

    test "with the empty appsignal_plug and appsignal_phoenix 3.x packages installed" do
      load_package(:appsignal_plug, "3.0.0")
      load_package(:appsignal_phoenix, "3.0.0")

      assert Dependencies.conflicts() == :ok
    end
  end

  describe "foreign?/2" do
    test "for a module loaded from the given ebin directory" do
      refute Dependencies.foreign?(
               ~c"/app/lib/appsignal/ebin/Elixir.Appsignal.Plug.beam",
               "/app/lib/appsignal/ebin"
             )
    end

    test "for a module loaded from another directory" do
      assert Dependencies.foreign?(
               ~c"/app/lib/appsignal_plug/ebin/Elixir.Appsignal.Plug.beam",
               "/app/lib/appsignal/ebin"
             )
    end

    test "for a module that is not loaded" do
      refute Dependencies.foreign?(:non_existing, "/app/lib/appsignal/ebin")
    end
  end

  describe "initialize/0 with appsignal_phoenix 2.x installed" do
    setup do
      start_supervised!(Appsignal.Test.Nif)
      load_package(:appsignal_phoenix, "2.8.2")
      setup_with_config(%{active: true})
    end

    test "deactivates AppSignal and logs why" do
      log = capture_log(fn -> Appsignal.initialize() end)

      refute Config.active?()
      assert log =~ "AppSignal is disabled, because appsignal_phoenix 2.8.2 is installed"
      assert log =~ "mix deps.unlock appsignal_plug appsignal_phoenix"
    end
  end
end
