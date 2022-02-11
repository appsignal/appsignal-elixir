defmodule FakeErlang do
  use TestAgent, %{system_info: 'x86_64-apple-darwin20.2.0'}

  def system_info(_), do: get(__MODULE__, :system_info)
end
