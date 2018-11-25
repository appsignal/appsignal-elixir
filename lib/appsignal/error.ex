defmodule Appsignal.Error do
  @moduledoc """
  Functions for extracting information from Elixir exceptions and Erlang errors.
  """
  alias Appsignal.Backtrace

  @spec metadata(any, Exception.stactrace()) :: {String.t(), String.t(), list(String.t())}
  if Appsignal.plug?() do
    def metadata(%Plug.Conn.WrapperError{reason: error, stack: _stacktrace}, stacktrace) do
      metadata(error, stacktrace)
    end
  end

  def metadata(%_{__exception__: true} = exception, stacktrace) do
    {
      name(exception),
      Exception.message(exception),
      Backtrace.from_stacktrace(stacktrace)
    }
  end

  def metadata({%_{__exception__: true} = exception, stacktrace}, _) do
    metadata(exception, stacktrace)
  end

  def metadata({{%_{__exception__: true} = exception, stacktrace}, _}, _) do
    metadata(exception, stacktrace)
  end

  def metadata({maybe_error, maybe_stacktrace} = error, stacktrace) do
    {error, stacktrace} =
      if(stacktrace?(maybe_stacktrace)) do
        {maybe_error, maybe_stacktrace}
      else
        {error, stacktrace}
      end

    :error
    |> Exception.normalize(error, stacktrace)
    |> metadata(stacktrace)
  end

  def metadata(error, stacktrace) do
    :error
    |> Exception.normalize(error, stacktrace)
    |> metadata(stacktrace)
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

  defp stacktrace?(stacktrace) when is_list(stacktrace) do
    Enum.all?(stacktrace, &stacktrace_line?/1)
  end

  defp stacktrace?(_), do: false

  defp stacktrace_line?({_, _, _, [file: _, line: _]}), do: true
  defp stacktrace_line?(_), do: false
end
