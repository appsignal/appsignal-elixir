defmodule Appsignal.Utils.ParamsEncoder do
  @moduledoc """
  Encoded parameters
  """

  def encode(payload) do
    payload
    |> preprocess
    |> Poison.encode!
  end

  @doc """
  Makes sure the keys are valid for JSON encoding
  """
  def preprocess(value) when is_map(value) do
    Enum.map(value, fn({k, v}) ->
      {safe_key(k), preprocess(v)}
    end)
    |> Enum.into(%{})
  end
  def preprocess(value) when is_list(value) do
    Enum.map(value, &preprocess/1)
  end
  def preprocess(value) when is_tuple(value), do: "#{inspect value}"
  def preprocess(value), do: value

  defp safe_key(k) when is_integer(k), do: Integer.to_string(k)
  defp safe_key(k) when is_atom(k), do: k
  defp safe_key(k) when is_binary(k), do: k
  defp safe_key(k), do: "#{inspect k}"

end
