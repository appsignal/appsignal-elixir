defmodule Appsignal.Utils do
  @moduledoc false

  @doc """
  Converts module name atoms to strings.

  ## Examples

      iex> Appsignal.Utils.module_name(MyModule)
      "MyModule"
      iex> Appsignal.Utils.module_name("MyModule")
      "MyModule"

  """
  @spec module_name(atom() | String.t()) :: String.t()
  def module_name("Elixir." <> module), do: module

  def module_name(module) when is_binary(module), do: module

  def module_name(module), do: module |> to_string() |> module_name()
end
