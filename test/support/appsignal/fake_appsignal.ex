defmodule Appsignal.FakeAppsignal do
  use TestAgent

  def set_gauge(key, value, _tags \\ %{}) do
    update(__MODULE__, key, value)
  end
end
