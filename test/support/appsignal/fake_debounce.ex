defmodule Appsignal.FakeDebounce do
  use Agent

  def start_link(opts \\ nil) do
    Agent.start_link(
      # Since `nil` is a valid value for `last_transmission_milliseconds`,
      # we use `:never_called` to differentiate when the function has
      # never been called.
      fn ->
        %{
          last_transmission_milliseconds: :never_called,
          debounce: 20
        }
      end,
      name: __MODULE__
    )
  end

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def milliseconds_until_next_transmission(last_transmission_milliseconds) do
    Agent.update(__MODULE__, fn state ->
      %{state | last_transmission_milliseconds: last_transmission_milliseconds}
    end)

    Agent.get(__MODULE__, & &1.debounce)
  end

  def last_transmission_milliseconds do
    Agent.get(__MODULE__, & &1.last_transmission_milliseconds)
  end

  def set_debounce(debounce) do
    Agent.update(__MODULE__, fn state ->
      %{state | debounce: debounce}
    end)
  end
end
