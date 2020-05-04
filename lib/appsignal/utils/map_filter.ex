defmodule Appsignal.Utils.MapFilter do
  @moduledoc false
  require Logger

  @doc """
  Filter parameters based on Appsignal and Phoenix configuration.
  """
  def filter_parameters(values), do: filter_values(values, get_filter_parameters())

  @doc """
  Filter session data based Appsignal configuration.
  """
  def filter_session_data(values), do: filter_values(values, get_filter_session_data())

  @doc false
  def filter_values(values, {:discard, params}), do: discard_values(values, params)
  def filter_values(values, {:keep, params}), do: keep_values(values, params)
  def filter_values(values, params), do: discard_values(values, params)

  def get_filter_parameters do
    merge_filters(
      Application.get_env(:appsignal, :config)[:filter_parameters],
      Application.get_env(:phoenix, :filter_parameters, [])
    )
  end

  def get_filter_session_data do
    Application.get_env(:appsignal, :config)[:filter_session_data] || []
  end

  defp discard_values(list, filter_keys) when is_list(list) do
    discard_values(list, filter_keys, [])
  end

  defp discard_values(%{__struct__: _} = struct, filter_keys) do
    struct
    |> Map.from_struct()
    |> discard_values(filter_keys)
  end

  defp discard_values(map, filter_keys) when is_map(map) do
    map
    |> Map.to_list()
    |> discard_values(filter_keys, [])
    |> Enum.into(%{})
  end

  defp discard_values(value, _filter_keys), do: value

  defp discard_values([{key, value} | tail], filter_keys, acc) do
    if (is_binary(key) or is_atom(key)) and to_string(key) in filter_keys do
      discard_values(tail, filter_keys, [{key, "[FILTERED]"} | acc])
    else
      discard_values(tail, filter_keys, [{key, discard_values(value, filter_keys)} | acc])
    end
  end

  defp discard_values([value | tail], filter_keys, acc) do
    discard_values(tail, filter_keys, [discard_values(value, filter_keys) | acc])
  end

  defp discard_values([], _filter_keys, acc), do: acc

  defp keep_values(list, keep_keys) when is_list(list) do
    keep_values(list, keep_keys, [])
  end

  defp keep_values(%{__struct__: _} = struct, keep_keys) do
    struct
    |> Map.from_struct()
    |> keep_values(keep_keys)
  end

  defp keep_values(map, keep_keys) when is_map(map) do
    map
    |> Map.to_list()
    |> keep_values(keep_keys, [])
    |> Enum.into(%{})
  end

  defp keep_values(_value, _keep_keys), do: "[FILTERED]"

  defp keep_values([{key, value} | tail], keep_keys, acc) do
    if (is_binary(key) or is_atom(key)) and to_string(key) in keep_keys do
      keep_values(tail, keep_keys, [{key, discard_values(value, [])} | acc])
    else
      keep_values(tail, keep_keys, [{key, keep_values(value, keep_keys)} | acc])
    end
  end

  defp keep_values([value | tail], keep_keys, acc) do
    keep_values(tail, keep_keys, [keep_values(value, keep_keys) | acc])
  end

  defp keep_values([], _keep_keys, acc), do: acc

  defp merge_filters(appsignal, phoenix) when is_list(appsignal) and is_list(phoenix) do
    appsignal ++ phoenix
  end

  defp merge_filters({:keep, appsignal}, {:keep, phoenix}), do: {:keep, appsignal ++ phoenix}

  defp merge_filters(appsignal, {:keep, phoenix}) when is_list(appsignal) and is_list(phoenix) do
    {:keep, phoenix -- appsignal}
  end

  defp merge_filters({:keep, appsignal}, phoenix) when is_list(appsignal) and is_list(phoenix) do
    {:keep, appsignal -- phoenix}
  end

  defp merge_filters(appsignal, phoenix) do
    Logger.error("""
    An error occured while merging parameter filters.

    AppSignal expects all parameter_filter values to be either a list of
    strings (`["email"]`), or a :keep-tuple with a list of strings as its
    second element (`{:keep, ["email"]}`).

    From the AppSignal configuration:

      #{inspect(appsignal)}

    From the Phoenix configuration:

      #{inspect(phoenix)}

    To ensure no sensitive parameters are sent, all parameters are filtered out
    for this transaction.
    """)

    {:keep, []}
  end
end
