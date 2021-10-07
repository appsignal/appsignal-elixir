defmodule Appsignal.Probes.FunctionProbeTest do
  alias Appsignal.Probes.FunctionProbe
  import AppsignalTest.Utils
  use ExUnit.Case
  require Logger

  describe "cast(:probe)" do
    setup do
      agent = start_supervised!({Agent, fn -> false end})

      function = fn ->
        Agent.update(agent, fn _ -> true end)
      end

      [
        agent: agent,
        function_probe: start_supervised!({FunctionProbe, [function]})
      ]
    end

    test "calls the function passed as state", %{
      agent: agent,
      function_probe: function_probe
    } do
      refute Agent.get(agent, fn state -> state end)

      GenServer.cast(function_probe, :probe)

      until(fn ->
        assert Agent.get(agent, fn state -> state end)
      end)
    end
  end
end
