defmodule Appsignal.Utils.DataEncoder do
  @moduledoc """
  Encodes data
  """

  alias Appsignal.Nif

  def encode(data) do
    {:ok, resource} = Nif.data_map_new
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
  def encode(resource, {key, value}) do
    encode(resource, {key, to_string(value)})
  end
end
