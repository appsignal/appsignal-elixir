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

  def encode(resource, {key, value}) do
    Nif.data_set_string(resource, key, value)
  end
end
