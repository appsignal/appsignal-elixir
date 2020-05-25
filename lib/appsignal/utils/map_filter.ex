defmodule Appsignal.Utils.MapFilter do
  @moduledoc false
  require Logger

  def filter(data) do
    filter(data, Application.get_env(:phoenix, :filter_parameters, []))
  end

  defp filter(data, {:keep, keys}) do
    {filtered, _} = Map.split(data, keys)
    filtered
  end

  defp filter(data, _), do: data
end
