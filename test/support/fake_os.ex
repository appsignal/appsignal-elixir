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

  def system_time, do: 1_653_474_764_790_125_080
end
