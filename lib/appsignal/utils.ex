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

  @deprecated "Use Logger.info/1 instead."
  def info(message) do
    require Logger
    Logger.info(message)
  end

  @deprecated "Use Logger.warning/1 instead."
  def warning(message) do
    require Logger
    Logger.warning(message)
  end

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
end
