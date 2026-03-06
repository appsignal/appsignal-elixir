defmodule FakeHTTPoisonBase do
  use TestAgent, %{raise: false}

  def set_raise(value) do
    Agent.update(__MODULE__, fn state -> %{state | raise: value} end)
  end

  def should_raise? do
    if alive?() do
      Agent.get(__MODULE__, & &1[:raise])
    else
      false
    end
  end

  defmacro __using__(_opts) do
    quote do
      def request(_method, _url, _body \\ "", _headers \\ [], _options \\ []) do
        if FakeHTTPoisonBase.should_raise?() do
          raise RuntimeError, "Simulated HTTP error"
        else
          {:ok, :fake_response}
        end
      end

      defoverridable request: 5
    end
  end
end
