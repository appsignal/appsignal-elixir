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

  describe "present?/1" do
    test "with the library loaded" do
      load_package(:appsignal_test_library, "1.7.0")

      assert Dependencies.present?(:appsignal_test_library)
    end

    test "without the library" do
      refute Dependencies.present?(:appsignal_test_library)
    end
  end

  describe "match?/2" do
    test "with a version that meets the requirement" do
      load_package(:appsignal_test_library, "1.8.15")

      assert Dependencies.match?(:appsignal_test_library, ">= 1.7.0")
    end

    test "with a pre-release of a version that meets the requirement" do
      load_package(:appsignal_test_library, "1.9.0-rc.0")

      assert Dependencies.match?(:appsignal_test_library, ">= 1.7.0")
    end

    test "with a version that does not meet the requirement" do
      load_package(:appsignal_test_library, "1.6.16")

      refute Dependencies.match?(:appsignal_test_library, ">= 1.7.0")
    end

    test "with a pre-release of the oldest version that meets the requirement" do
      load_package(:appsignal_test_library, "1.7.0-rc.0")

      refute Dependencies.match?(:appsignal_test_library, ">= 1.7.0")
    end

    test "with a version that cannot be parsed" do
      load_package(:appsignal_test_library, "one point seven")

      refute Dependencies.match?(:appsignal_test_library, ">= 1.7.0")
    end

    test "without the library" do
      refute Dependencies.match?(:appsignal_test_library, ">= 0.0.0")
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
