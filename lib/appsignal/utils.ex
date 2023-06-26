defmodule Appsignal.Utils do
  @moduledoc false

  require Logger

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

  defdelegate info(message), to: Logger
  defdelegate warning(message), to: Logger

  defmacro compile_env(app, key, default \\ nil) do
    quote do
      Application.compile_env(unquote(app), unquote(key), unquote(default))
    end
  end
end
