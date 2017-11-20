defmodule Appsignal.FakeSystem do
  @behaviour Appsignal.SystemBehaviour
  use TestAgent, %{uid: 999, heroku: false, root: false}

  def hostname_with_domain, do: "Alices-MBP.example.com"

  def root?, do: get(__MODULE__, :root)

  def heroku?, do: get(__MODULE__, :heroku)

  def uid, do: get(__MODULE__, :uid)
end
