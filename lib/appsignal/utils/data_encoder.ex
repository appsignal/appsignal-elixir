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

  def encode(resource, {key, value}) when is_binary(key) do
    Nif.data_set_string(resource, key, value)
  end
  def encode(resource, {key, value}) do
    encode(resource, {to_string(key), value})
  end
end
