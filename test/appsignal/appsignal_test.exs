defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils

  setup do
    {:ok, _} = start_supervised(Appsignal.Test.Tracer)
    {:ok, _} = start_supervised(Appsignal.Test.Nif)
    {:ok, _} = start_supervised(Appsignal.Test.Span)
    {:ok, _} = start_supervised(Appsignal.Test.Monitor)
    {:ok, _} = start_supervised(FakeIO)

    [fake_os: start_supervised!(FakeOS)]
  end

  describe "initialize" do
    @tag :skip_env_test
    test "prints warning about extension not being loaded" do
      Appsignal.initialize()
      [{:stderr, device_output}] = FakeIO.all()
      output = String.trim(device_output)

      assert output ==
               "[appsignal][ERROR] AppSignal failed to load the extension. Please run the diagnose tool and email us at support@appsignal.com: https://docs.appsignal.com/elixir/command-line/diagnose.html"
    end

    @tag :skip_env_test
    test "prints warning about mismatch extension architecture", %{
      fake_os: fake_os
    } do
      # Make current OS "unknown" value so it will always fail
      FakeOS.update(fake_os, :type, {:unknown, :unknown})
      Appsignal.initialize()
      [{:stderr, device_output}] = FakeIO.all()
      output = String.trim(device_output)

      assert output =~
               ~r{AppSignal NIF was installed for architecture '\w+-\w+', but the current architecture is '\w+-unknown'}
    end
  end

  describe "initialize when the JSON file not valid" do
    setup do
      install_report = Path.join([:code.priv_dir(:appsignal), "install.report"])
      install_contents = File.read!(install_report)
      File.write(install_report, "invalid install report JSON")

      on_exit(:reset, fn ->
        File.write!(install_report, install_contents)
      end)
    end

    @tag :skip_env_test
    test "logs an error that the report file is invalid" do
      Appsignal.initialize()

      [{:stderr, _architecture_mismatch_error}, {:stderr, report_error}] = FakeIO.all()

      assert report_error =~
               ~r{Failed to parse the AppSignal 'install.report' file:}
    end
  end

  describe "initialize when the report file is not readable" do
    setup do
      install_report = Path.join([:code.priv_dir(:appsignal), "install.report"])
      File.chmod(install_report, 0o000)

      on_exit(:reset, fn ->
        File.chmod(install_report, 0o644)
      end)
    end

    @tag :skip_env_test
    test "logs an error when the report file is not found" do
      Appsignal.initialize()

      [{:stderr, _architecture_mismatch_error}, {:stderr, report_error}] = FakeIO.all()

      assert report_error =~
               ~r{Failed to read the AppSignal 'install.report' file:}
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

      env = Appsignal.Config.get_system_env()
      assert "test" = env["APPSIGNAL_APP_ENV"]

      config = Application.get_env(:appsignal, :config)
      assert :test = config[:env]
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
