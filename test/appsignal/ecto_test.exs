defmodule Appsignal.EctoTest do
  use ExUnit.Case

  test "is attached to the repo query event automatically" do
    assert attached?([:appsignal, :test, :repo, :query])
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Ecto, event}
    end)
  end
end
