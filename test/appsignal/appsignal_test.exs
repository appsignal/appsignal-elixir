defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils
  alias Appsignal.Diagnose.FakeInstallationReport

  setup do
    {:ok, _} = start_supervised(Appsignal.Test.Tracer)
    {:ok, _} = start_supervised(Appsignal.Test.Nif)
    {:ok, _} = start_supervised(Appsignal.Test.Span)
    {:ok, _} = start_supervised(Appsignal.Test.Monitor)
    {:ok, _} = start_supervised(FakeIO)

    fake_installation_report = start_supervised!(FakeInstallationReport)

    [fake_os: start_supervised!(FakeOS), fake_installation_report: fake_installation_report]
  end

  # Build a minimal install report JSON whose arch/target matches FakeOS's default {unix, linux}
  defp matching_install_json do
    arch =
      List.first(
        String.split(to_string(:erlang.system_info(:system_architecture)), "-", parts: 2)
      )

    Jason.encode!(%{"build" => %{"architecture" => "#{arch}-linux", "target" => "linux"}})
  end

  describe "initialize" do
    setup %{fake_installation_report: fake_ir} do
      FakeInstallationReport.update(fake_ir, :install, {:ok, matching_install_json()})
      :ok
    end

    @tag :skip_env_test
    test "prints warning about extension not being loaded" do
      Appsignal.initialize()
      [{:stderr, device_output}] = FakeIO.all()
      output = String.trim(device_output)

      assert output ==
               "[appsignal][ERROR] AppSignal failed to load the extension. Please run the diagnose tool and email us at support@appsignal.com: https://docs.appsignal.com/elixir/command-line/diagnose.html"
    end

    @tag :skip_env_test
    test "prints warning about mismatch extension architecture", %{fake_os: fake_os} do
      FakeOS.update(fake_os, :type, {:unknown, :unknown})
      Appsignal.initialize()
      [{:stderr, device_output}] = FakeIO.all()
      output = String.trim(device_output)

      assert output =~
               ~r{AppSignal NIF was installed for architecture '\w+-\w+', but the current architecture is '\w+-unknown'}
    end
  end

  describe "initialize when the install report JSON is invalid" do
    setup %{fake_installation_report: fake_ir} do
      FakeInstallationReport.update(fake_ir, :install, {:ok, "invalid install report JSON"})
      :ok
    end

    @tag :skip_env_test
    test "logs a parse error and an architecture mismatch" do
      Appsignal.initialize()

      [{:stderr, _architecture_mismatch_error}, {:stderr, report_error}] = FakeIO.all()

      assert report_error =~ ~r{Failed to parse the AppSignal 'install.report' file:}
    end
  end

  describe "initialize when the install report cannot be read" do
    setup %{fake_installation_report: fake_ir} do
      FakeInstallationReport.update(fake_ir, :install, {:error, :eacces})
      :ok
    end

    @tag :skip_env_test
    test "logs a read error and an architecture mismatch" do
      Appsignal.initialize()

      [{:stderr, _architecture_mismatch_error}, {:stderr, report_error}] = FakeIO.all()

      assert report_error =~ ~r{Failed to read the AppSignal 'install.report' file:}
    end
  end

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
    Appsignal.set_gauge("key", 10)
    Appsignal.set_gauge("key", 10.0, %{:a => "b"})
    Appsignal.set_gauge("key", 10, %{:a => "b"})
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
    Appsignal.increment_counter("counter", 5, %{:a => "b"})
    Appsignal.increment_counter("counter", 5.0)
    Appsignal.increment_counter("counter", 5.0, %{:a => "b"})
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
    Appsignal.add_distribution_value("dist_key", 10)
    Appsignal.add_distribution_value("dist_key", 10.0, %{:a => "b"})
    Appsignal.add_distribution_value("dist_key", 10, %{:a => "b"})
  end

  test "Agent environment variables" do
    with_env(%{"APPSIGNAL_APP_ENV" => "test"}, fn ->
      Appsignal.Config.initialize()

      until(fn ->
        env = Appsignal.Config.get_system_env()
        assert "test" = env["APPSIGNAL_APP_ENV"]

        config = Application.get_env(:appsignal, :config)
        assert :test = config[:env]
      end)
    end)
  end

  describe "instrument/1" do
    test "delegates to Appsignal.Instrumentation" do
      assert :ok = Appsignal.instrument(fn -> :ok end)
    end
  end

  describe "instrument/2" do
    test "delegates to Appsignal.Instrumentation" do
      assert :ok = Appsignal.instrument("name", fn -> :ok end)
    end
  end

  describe "instrument/3" do
    test "delegates to Appsignal.Instrumentation" do
      assert :ok = Appsignal.instrument("name", "category", fn -> :ok end)
    end
  end

  describe "send_error/2" do
    test "delegates to Appsignal.Instrumentation" do
      assert %Appsignal.Span{} = Appsignal.send_error(%RuntimeError{}, [])
    end
  end

  describe "send_error/3" do
    test "delegates to Appsignal.Instrumentation" do
      assert %Appsignal.Span{} = Appsignal.send_error(:error, %RuntimeError{}, [])
    end
  end

  describe "send_error/4" do
    test "delegates to Appsignal.Instrumentation" do
      assert %Appsignal.Span{} =
               Appsignal.send_error(:error, %RuntimeError{}, [], fn span -> span end)
    end
  end

  describe "set_error/2" do
    test "delegates to Appsignal.Instrumentation" do
      assert Appsignal.set_error(%RuntimeError{}, []) == nil
    end
  end

  describe "set_error/3" do
    test "delegates to Appsignal.Instrumentation" do
      assert Appsignal.set_error(:error, %RuntimeError{}, []) == nil
    end
  end
end
