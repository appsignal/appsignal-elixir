defmodule Appsignal.Utils.MapFilter do
  @moduledoc false
  require Logger

  # Phoenix parameter filtering copied from to ensure we support the same filtering options:
  # https://github.com/phoenixframework/phoenix/blob/dfb0c00d2077e10f8df6cc6e334e04924c4c2bcd/lib/phoenix/logger.ex#L157-L199

  def filter(values, params \\ Application.get_env(:phoenix, :filter_parameters, []))
  def filter(values, {:discard, params}), do: discard_values(values, params)
  def filter(values, {:keep, params}), do: keep_values(values, params)
  def filter(values, params), do: discard_values(values, params)

  defp discard_values(%{__struct__: mod} = struct, _params) when is_atom(mod) do
    struct
  end

  defp discard_values(%{} = map, params) do
    Enum.into(map, %{}, fn {k, v} ->
      if is_binary(k) and String.contains?(k, params) do
        {k, "[FILTERED]"}
      else
        {k, discard_values(v, params)}
      end
    end)
  end

  defp discard_values([_ | _] = list, params) do
    Enum.map(list, &discard_values(&1, params))
  end

  defp discard_values(other, _params), do: other

  defp keep_values(%{__struct__: mod}, _params) when is_atom(mod), do: "[FILTERED]"

  defp keep_values(%{} = map, params) do
    Enum.into(map, %{}, fn {k, v} ->
      if is_binary(k) and k in params do
        {k, discard_values(v, [])}
      else
        {k, keep_values(v, params)}
      end
    end)
  end

  defp keep_values([_ | _] = list, params) do
    Enum.map(list, &keep_values(&1, params))
  end

  defp keep_values(_other, _params), do: "[FILTERED]"
end
