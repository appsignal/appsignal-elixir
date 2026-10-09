if Appsignal.Dependencies.present?(:httpoison) do
  defmodule Appsignal.HTTPoisonAPITest do
    use ExUnit.Case, async: true

    defmodule UninstrumentedClient do
      use HTTPoison.Base
    end

    defmodule Client do
      use Appsignal.HTTPoison.Base
    end

    test "Appsignal.HTTPoison has the functions and deprecations HTTPoison has" do
      assert api(Appsignal.HTTPoison) == api(HTTPoison)
    end

    test "a client using Appsignal.HTTPoison.Base has the functions and deprecations of one using HTTPoison.Base" do
      assert api(Client) == api(UninstrumentedClient)
    end

    defp api(module) do
      %{
        functions: Enum.sort(module.__info__(:functions)),
        deprecated: Enum.sort(module.__info__(:deprecated))
      }
    end
  end
end
