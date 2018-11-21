defmodule Appsignal.Error do
  @moduledoc """
  Functions for extracting information from Elixir exceptions and Erlang errors.
  """
  alias Appsignal.Backtrace

  @spec metadata(any, Exception.stactrace()) :: {String.t(), String.t(), list(String.t())}
  def metadata(error, stacktrace) do
    %module{} = exception = Exception.normalize(:error, error)

    {
      module_name(module),
      Exception.message(exception),
      Backtrace.from_stacktrace(stacktrace)
    }
  end

  @spec module_name(atom | String.t()) :: String.t()
  defp module_name(module) when is_atom(module) do
    module
    |> Atom.to_string()
    |> module_name
  end

  defp module_name("Elixir." <> module), do: module
end
