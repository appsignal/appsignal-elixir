defmodule Appsignal.Utils.DataEncoder do
  @moduledoc false

  alias Appsignal.Nif

  def encode(%{__struct__: _} = data) do
    data |> Map.from_struct() |> encode
  end

  def encode(data) when is_tuple(data) do
    data |> Tuple.to_list() |> encode
  end

  def encode(data) when is_map(data) do
    {:ok, resource} = Nif.data_map_new()
    Enum.each(data, fn item -> encode(resource, item) end)
    resource
  end

  def encode(data) when is_list(data) do
    {:ok, resource} = Nif.data_list_new()

    Enum.each(data, fn item ->
      if is_map(item) or is_tuple(item) do
        Nif.data_set_data(resource, encode(item))
      else
        if is_list(item) do
          if proper_list?(item) do
            Nif.data_set_data(resource, encode(item))
          else
            Nif.data_set_string(
              resource,
              "improper_list:#{inspect(item)}"
            )
          end
        else
          encode(resource, item)
        end
      end
    end)

    resource
  end

  def encode(resource, {key, value}) when is_atom(key) do
    encode(resource, {to_string(key), value})
  end

  def encode(resource, {key, value}) when not is_binary(key) do
    encode(resource, {inspect(key), value})
  end

  def encode(resource, {key, value}) when is_binary(value) do
    Nif.data_set_string(resource, key, value)
  end

  def encode(resource, {key, value})
      when is_integer(value) and value >= 9_223_372_036_854_775_808 do
    Nif.data_set_string(resource, key, "bigint:#{value}")
  end

  def encode(resource, {key, value}) when is_integer(value) do
    Nif.data_set_integer(resource, key, value)
  end

  def encode(resource, {key, value}) when is_float(value) do
    Nif.data_set_float(resource, key, value)
  end

  def encode(resource, {key, value}) when is_map(value) or is_tuple(value) do
    Nif.data_set_data(resource, key, encode(value))
  end

  def encode(resource, {key, value}) when is_list(value) do
    if proper_list?(value) do
      Nif.data_set_data(resource, key, encode(value))
    else
      Nif.data_set_string(
        resource,
        key,
        "improper_list:#{inspect(value)}"
      )
    end
  end

  def encode(resource, {key, true}) do
    Nif.data_set_boolean(resource, key, 1)
  end

  def encode(resource, {key, false}) do
    Nif.data_set_boolean(resource, key, 0)
  end

  def encode(resource, {key, nil}) do
    Nif.data_set_nil(resource, key)
  end

  def encode(resource, {key, value}) when is_atom(value) do
    encode(resource, {key, to_string(value)})
  end

  def encode(resource, {key, value}) do
    encode(resource, {key, inspect(value)})
  end

  def encode(resource, value) when is_binary(value) do
    Nif.data_set_string(resource, value)
  end

  def encode(resource, value) when is_integer(value) and value >= 9_223_372_036_854_775_808 do
    Nif.data_set_string(resource, "bigint:#{value}")
  end

  def encode(resource, value) when is_integer(value) do
    Nif.data_set_integer(resource, value)
  end

  def encode(resource, value) when is_float(value) do
    Nif.data_set_float(resource, value)
  end

  def encode(resource, value) when is_map(value) or is_tuple(value) do
    Nif.data_set_data(resource, encode(value))
  end

  def encode(resource, value) when is_list(value) do
    if proper_list?(value) do
      Nif.data_set_data(resource, encode(value))
    else
      Nif.data_set_string(
        resource,
        "improper_list:#{inspect(value)}"
      )
    end
  end

  def encode(resource, true) do
    Nif.data_set_boolean(resource, 1)
  end

  def encode(resource, false) do
    Nif.data_set_boolean(resource, 0)
  end

  def encode(resource, nil) do
    Nif.data_set_nil(resource)
  end

  def encode(resource, value) when is_atom(value) do
    encode(resource, to_string(value))
  end

  def encode(resource, value) do
    encode(resource, inspect(value))
  end

  def proper_list?([_head | tail]) when is_list(tail) do
    proper_list?(tail)
  end

  def proper_list?([]), do: true
  def proper_list?(_), do: false
end
