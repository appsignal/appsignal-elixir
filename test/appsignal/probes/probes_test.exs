defmodule Appsignal.Probes.ProbesTest do
  use ExUnit.Case, async: false

  alias Appsignal.Probes

  describe "register/2" do
    test "does register a probe when given a function as probe" do
      assert :ok == Probes.register(:some_probe, fn -> nil end)
    end

    test "returns an error tupple when probe is not a function" do
      assert {:error, _} = Probes.register(:some_probe, :some_value)
    end
  end
end
