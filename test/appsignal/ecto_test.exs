defmodule Appsignal.EctoTest do
  use ExUnit.Case
  alias Appsignal.Ecto

  test "is attached to the repo query event automatically" do
    assert attached?([:appsignal, :test, :repo, :query])
  end

  test "attach/2 attaches to events with custom prefixes" do
    Application.put_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: [:my_repo])
    Ecto.attach(:appsignal, Appsignal.Test.Repo)

    assert attached?([:my_repo, :query])

    Application.delete_env(:appsignal, Appsignal.Test.Repo, telemetry_prefix: :my_repo)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Ecto, event}
    end)
  end
end
