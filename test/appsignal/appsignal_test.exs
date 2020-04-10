defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils

  alias Appsignal.{FakeTransaction, Span, Test, Tracer, WrappedNif}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
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

  describe "instrument/2" do
    setup do
      WrappedNif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

      %{return: Appsignal.instrument("test", fn -> :ok end)}
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "test"}]} = Test.Span.get(:set_name)
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/2, when a root span exists" do
    setup do
      WrappedNif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

      %{
        parent: Tracer.create_span("http_request"),
        return: Appsignal.instrument("test", fn -> :ok end)
      }
    end

    test "creates a child span", %{parent: parent} do
      assert {:ok, [{"http_request", ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "test"}]} = Test.Span.get(:set_name)
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/2, when passing a function that takes an argument" do
    setup do
      WrappedNif.start_link()
      Test.Tracer.start_link()
      Test.Span.start_link()

      %{return: Appsignal.instrument("test", fn span -> span end)}
    end

    test "calls the passed function with the created span, and returns its return", %{
      return: return
    } do
      assert %Span{} = return
    end
  end
end
