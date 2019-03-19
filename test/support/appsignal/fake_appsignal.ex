defmodule Appsignal.FakeAppsignal do
  use TestAgent

  def set_gauge(key, value, tags \\ %{}) do
    update(__MODULE__, key, value)
  end
end
