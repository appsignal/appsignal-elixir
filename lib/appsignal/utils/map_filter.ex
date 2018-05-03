defmodule Appsignal.Utils.MapFilter do
  @moduledoc """
  Helper functions for filtering parameters to prevent sensitive data
  to be submitted to AppSignal.
  """

  def get_filter_parameters do
    Application.get_env(:appsignal, :config)[:filter_parameters]
    || Application.get_env(:phoenix, :filter_parameters)
    || []
  end

  def filter_values(values) do
    filter_values(values, get_filter_parameters())
  end

  def filter_values(%{__struct__: mod} = struct, _filter_params) when is_atom(mod) do
    struct
  end
  def filter_values(%{} = map, filter_params) do
    Enum.into map, %{}, fn{k, v} ->
      if is_binary(k) and String.contains?(k, filter_params) do
        {k, "[FILTERED]"}
      else
        {k, filter_values(v, filter_params)}
      end
    end
  end
  def filter_values([_|_] = list, filter_params) do
    Enum.map(list, &filter_values(&1, filter_params))
  end
  def filter_values(other, _filter_params), do: other
end
