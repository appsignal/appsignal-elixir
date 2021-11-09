defmodule Appsignal.Utils.MapFilter do
  # TO-DO: Move this module to the Phoenix package, affter
  # `Appsignal.Span.set_sample_data/3` is removed.

  @moduledoc false
  require Logger

  def filter(data) do
    filter(data, Application.get_env(:phoenix, :filter_parameters, []))
  end

  defp filter(data, {:keep, keys}) do
    Enum.into(data, %{}, fn {key, value} ->
      new_value = if key in keys, do: value, else: "[FILTERED]"
      {key, new_value}
    end)
  end

  defp filter(data, _), do: data
end
