defmodule Appsignal.FakeSystem do
  @behaviour Appsignal.SystemBehaviour

  def hostname_with_domain do
    "Alices-MBP.example.com"
  end
end
