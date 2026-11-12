if Appsignal.Dependencies.present?(:httpoison) do
  defmodule Appsignal.HTTPoisonAPITest do
    use ExUnit.Case, async: true

    defmodule UninstrumentedClient do
      use HTTPoison.Base
    end

    defmodule Client do
      use Appsignal.HTTPoison.Base
    end

    describe "Appsignal.HTTPoison" do
      test "has the functions HTTPoison has" do
        assert info(Appsignal.HTTPoison, :functions) == info(HTTPoison, :functions)
      end

      test "has the deprecations HTTPoison has" do
        assert info(Appsignal.HTTPoison, :deprecated) == info(HTTPoison, :deprecated)
      end
    end

    describe "a client using Appsignal.HTTPoison.Base" do
      test "has the functions of one using HTTPoison.Base" do
        assert info(Client, :functions) == info(UninstrumentedClient, :functions)
      end

      test "has the deprecations of one using HTTPoison.Base" do
        assert info(Client, :deprecated) == info(UninstrumentedClient, :deprecated)
      end
    end

    defp info(module, key), do: Enum.sort(module.__info__(key))
  end
end
