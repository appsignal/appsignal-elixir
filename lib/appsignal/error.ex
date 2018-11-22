defmodule Appsignal.Error do
  @moduledoc """
  Functions for extracting information from Elixir exceptions and Erlang errors.
  """
  alias Appsignal.Backtrace

  @spec metadata(any, Exception.stactrace()) :: {String.t(), String.t(), list(String.t())}
  def metadata(%Plug.Conn.WrapperError{reason: error, stack: _stacktrace}, stacktrace) do
    metadata(error, stacktrace)
  end

  def metadata({{%_{__exception__: true} = error, stacktrace}, _}, _) do
    metadata(error, stacktrace)
  end

  def metadata({%_{__exception__: true} = error, stacktrace}, _) do
    metadata(error, stacktrace)
  end

  def metadata(error, stacktrace) do
    exception = Exception.normalize(:error, error)

    {
      name(exception),
      Exception.message(exception),
      Backtrace.from_stacktrace(stacktrace)
    }
  end

  @spec name(Exception.t()) :: String.t()
  defp name(%ErlangError{original: {name, _}}) when is_atom(name) do
    inspect(name)
  end

  defp name(%ErlangError{original: name}) when is_atom(name) do
    inspect(name)
  end

  defp name(%module{}) do
    module_name(module)
  end

  @spec module_name(atom | String.t()) :: String.t()
  defp module_name(module) when is_atom(module) do
    module
    |> Atom.to_string()
    |> module_name
  end

  defp module_name("Elixir." <> module), do: module
end
