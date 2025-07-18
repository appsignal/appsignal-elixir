defmodule Appsignal.Utils.MapFilter do
  @moduledoc false
  require Logger

  # Phoenix parameter filtering adapted from the Phoenix Framework.
  # Copyright (c) 2014 Chris McCord - Licensed under MIT
  #
  # Phoenix < 1.18: https://github.com/phoenixframework/phoenix/blob/dfb0c00d2077e10f8df6cc6e334e04924c4c2bcd/lib/phoenix/logger.ex#L157-L199
  # Phoenix >= 1.18: https://github.com/phoenixframework/phoenix/blob/8a6baa5e2ddc9cf7a2fc797ac907c40389139122/lib/phoenix/logger.ex#L180-L228

  def filter(values, filter \\ Application.get_env(:phoenix, :filter_parameters, [])) do
    case filter do
      # Phoenix >= 1.18
      {:compiled, key_match, value_match} ->
        discard_values(values, key_match, value_match)

      # Phoenix < 1.18
      {:discard, params} ->
        discard_values(values, params)

      {:keep, match} ->
        keep_values(values, match)

      # Phoenix < 1.18
      params ->
        discard_values(values, params)
    end
  end

  # Phoenix >= 1.18
  defp discard_values(%{__struct__: mod} = struct, _key_match, _value_match) when is_atom(mod) do
    struct
  end

  defp discard_values(%{} = map, key_match, value_match) do
    Enum.into(map, %{}, fn {k, v} ->
      cond do
        is_binary(k) and String.contains?(k, key_match) ->
          {k, "[FILTERED]"}

        is_binary(v) and String.contains?(v, value_match) ->
          {k, "[FILTERED]"}

        true ->
          {k, discard_values(v, key_match, value_match)}
      end
    end)
  end

  defp discard_values([_ | _] = list, key_match, value_match) do
    Enum.map(list, &discard_values(&1, key_match, value_match))
  end

  defp discard_values(other, _key_match, _value_match), do: other

  # Phoenix < 1.18
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

  defp keep_values(%{__struct__: mod}, _match) when is_atom(mod), do: "[FILTERED]"

  defp keep_values(%{} = map, match) do
    Enum.into(map, %{}, fn {k, v} ->
      if is_binary(k) and k in match do
        {k, v}
      else
        {k, keep_values(v, match)}
      end
    end)
  end

  defp keep_values([_ | _] = list, match) do
    Enum.map(list, &keep_values(&1, match))
  end

  defp keep_values(_other, _match), do: "[FILTERED]"
end
