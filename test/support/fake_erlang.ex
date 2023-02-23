defmodule FakeErlang do
  use TestAgent, %{system_architecture: ~c"x86_64-apple-darwin20.2.0"}

  def system_info(:system_architecture), do: get(__MODULE__, :system_architecture)
  def system_info(key), do: :erlang.system_info(key)
end
