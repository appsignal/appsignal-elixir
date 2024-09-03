defmodule FakeSystem do
  use TestAgent, %{cmd: fn _, _, _ -> raise "oh no!" end}

  def cmd(command, args, opts \\ []) do
    get(__MODULE__, :cmd).(command, args, opts)
  end

  def system_time(_atom) do
    1_000_000_000
  end
end
