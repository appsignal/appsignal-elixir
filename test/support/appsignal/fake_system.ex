defmodule Appsignal.FakeSystem do
  @behaviour Appsignal.SystemBehaviour
  use TestAgent, %{uid: 999, heroku: false, root: false}

  def root?, do: get(__MODULE__, :root)

  def heroku?, do: get(__MODULE__, :heroku)

  def uid, do: get(__MODULE__, :uid)

  def priv_dir, do: get(__MODULE__, :priv_dir)

  def agent_platform, do: get(__MODULE__, :agent_platform)
end
