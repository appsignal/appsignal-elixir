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
end
