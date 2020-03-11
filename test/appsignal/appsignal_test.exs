defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils
  import ExUnit.CaptureIO

  alias Appsignal.FakeTransaction

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

  describe "phoenix?/0" do
    @tag :skip_env_test
    @tag :skip_env_test_no_nif
    test "is true when Phoenix is loaded" do
      assert Appsignal.phoenix?() == true
    end

    @tag :skip_env_test_phoenix
    test "is false when Phoenix is not loaded" do
      assert Appsignal.phoenix?() == false
    end
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
end
