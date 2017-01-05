defmodule Appsignal.Utils.DataEncoder do
  @moduledoc """
  Encodes data
  """

  alias Appsignal.Nif

  def encode(data) when is_map(data) do
    {:ok, resource} = Nif.data_map_new
    Enum.each(data, fn(item) -> encode(resource, item) end)
    resource
  end
  def encode(data) when is_list(data) do
    {:ok, resource} = Nif.data_list_new
    Enum.each(data, fn(item) -> encode(resource, item) end)
    resource
  end

  def encode(resource, {key, value}) when not is_binary(key) do
    encode(resource, {to_string(key), value})
  end
  def encode(resource, {key, value}) when is_binary(value) do
    Nif.data_set_string(resource, key, value)
  end
  def encode(resource, {key, value}) when is_integer(value) do
    Nif.data_set_integer(resource, key, value)
  end
  def encode(resource, {key, value}) when is_float(value) do
    Nif.data_set_float(resource, key, value)
  end
  def encode(resource, {key, value}) when is_map(value) do
    Nif.data_set_data(resource, key, encode(value))
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
  def encode(resource, {key, value}) do
    encode(resource, {key, to_string(value)})
  end
  def encode(resource, value) when is_integer(value) do
    Nif.data_set_integer(resource, value)
  end
  def encode(resource, value) when is_float(value) do
    Nif.data_set_float(resource, value)
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
  def encode(resource, value) do
    Nif.data_set_string(resource, value)
  end
end
