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

  defmacro compile_env(app, key, default \\ nil) do
    if Version.match?(System.version(), ">= 1.10.0") do
      quote do
        Application.compile_env(unquote(app), unquote(key), unquote(default))
      end
    else
      quote do
        Application.get_env(unquote(app), unquote(key), unquote(default))
      end
    end
  end

  case Version.compare(System.version(), "1.10.0") do
    :lt -> defdelegate warning(message), to: Logger, as: :warn
    _ -> defdelegate warning(message), to: Logger
  end
end
