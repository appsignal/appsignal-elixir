defmodule Appsignal.Utils.DataEncoder do
  @moduledoc """
  Encodes data
  """

  alias Appsignal.Nif

  def encode(_) do
    {:ok, resource} = Nif.data_map_new
    resource
  end
end
