defmodule FakeOS do
  use TestAgent, %{type: {:unix, :linux}}

  def type, do: get(__MODULE__, :type)
end
