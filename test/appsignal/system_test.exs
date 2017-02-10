defmodule Appsignal.SystemTest do
  use ExUnit.Case, async: false

  import Mock

  test "hostname_with_domain" do
    with_mocks([
      {:inet_udp, [:unstick], [open: fn(0) -> {:ok, "PORT"} end]},
      {:inet, [:unstick], [gethostname: fn("PORT") -> {:ok, "Alices-MBP.example.com"} end]},
      {:inet_udp, [:unstick], [close: fn("PORT") -> :ok end]}
    ]) do
      assert "Alices-MBP.example.com" == Appsignal.System.hostname_with_domain()
      assert called :inet_udp.close("PORT")
    end
  end

  test "hostname_with_domain, when unable to upen a UDP socket" do
    with_mocks([
      {:inet_udp, [:unstick], [open: fn(0) -> {:error, :eacces} end]}
    ]) do
      assert nil == Appsignal.System.hostname_with_domain()
    end
  end

  describe "when on Heroku" do
    setup do
      System.put_env "DYNO", "1"
      on_exit fn ->
        System.delete_env "DYNO"
      end
    end

    test "returns true" do
      assert Appsignal.System.heroku?
    end
  end

  describe "when not on Heroku" do
    setup do
      System.delete_env "DYNO"
    end

    test "returns false" do
      refute Appsignal.System.heroku?
    end
  end
end
