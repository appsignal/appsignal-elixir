defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils

  setup do
    {:ok, _} = start_supervised(Appsignal.Test.Tracer)
    {:ok, _} = start_supervised(Appsignal.Test.Nif)
    {:ok, _} = start_supervised(Appsignal.Test.Span)
    {:ok, _} = start_supervised(Appsignal.Test.Monitor)

    :ok
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
