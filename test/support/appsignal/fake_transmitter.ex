defmodule Appsignal.FakeTransmitter do
  use Agent

  def start_link do
    Agent.start_link(
      fn ->
        %{
          transmitted: [],
          response: {:ok, 200, :fake, :fake}
        }
      end,
      name: __MODULE__
    )
  end

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def transmit(url, payload, config) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(state, :transmitted, &[{url, payload, config} | &1])
    end)

    Agent.get(__MODULE__, & &1[:response])
  end

  def transmitted do
    Agent.get(__MODULE__, &Enum.reverse(&1[:transmitted]))
  end

  def transmitted_payloads do
    Enum.map(transmitted(), fn {_url, payload, _config} -> payload end)
  end
end
