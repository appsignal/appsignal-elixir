if Appsignal.Dependencies.present?(:httpoison) do
  defmodule Appsignal.HTTPoisonAPITest do
    use ExUnit.Case, async: true

    test "Appsignal.HTTPoison has the functions and deprecations HTTPoison has" do
      assert api(Appsignal.HTTPoison) == api(HTTPoison)
    end

    defp api(module) do
      %{
        functions: Enum.sort(module.__info__(:functions)),
        deprecated: Enum.sort(module.__info__(:deprecated))
      }
    end
  end
end
