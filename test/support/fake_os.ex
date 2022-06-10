defmodule FakeOS do
  use TestAgent, %{type: {:unix, :linux}}

  def type do
    if alive?() do
      get(__MODULE__, :type)
    else
      # Fall back on original implementation if the fake process is not alive
      :os.type()
    end
  end
end
