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

  @doc """
  Converts a native-unit duration to fractional milliseconds, preserving
  sub-millisecond precision. Use this when reporting timings as distribution
  metric values.

  ## Examples

      iex> Appsignal.Utils.native_to_milliseconds(System.convert_time_unit(1500, :microsecond, :native))
      1.5

  """
  @spec native_to_milliseconds(integer()) :: float()
  def native_to_milliseconds(native) when is_integer(native) do
    System.convert_time_unit(native, :native, :microsecond) / 1000
  end

  def info(message) do
    require Logger
    Logger.info(message)
  end

  def warning(message) do
    require Logger
    Logger.warning(message)
  end

  defmacro compile_env(app, key, default \\ nil) do
    quote do
      Application.compile_env(unquote(app), unquote(key), unquote(default))
    end
  end
end
