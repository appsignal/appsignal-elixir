defmodule Appsignal.Error do
  @moduledoc """
  Functions for extracting information from Elixir exceptions and Erlang errors.
  """
  import Appsignal.Utils

  @spec metadata(Exception.t()) :: {String.t(), String.t()}
  def metadata(exception) do
    {name(exception), Exception.message(exception)}
  end

  @spec normalize(any, Exception.stacktrace()) :: {Exception.t(), list(String.t())}
  if Appsignal.plug?() do
    def normalize(%Plug.Conn.WrapperError{reason: error, stack: _stacktrace}, stacktrace) do
      normalize(error, stacktrace)
    end
  end

  def normalize({%_{__exception__: true} = exception, stacktrace}, _) do
    normalize(exception, stacktrace)
  end

  def normalize({{%_{__exception__: true} = exception, stacktrace}, _}, _) do
    normalize(exception, stacktrace)
  end

  def normalize({maybe_error, maybe_stacktrace} = error, stacktrace) do
    {error, stacktrace} =
      if stacktrace?(maybe_stacktrace) do
        {maybe_error, maybe_stacktrace}
      else
        {error, stacktrace}
      end

    do_normalize(error, stacktrace)
  end

  def normalize(error, stacktrace), do: do_normalize(error, stacktrace)

  @spec do_normalize(any, Exception.stacktrace()) :: {Exception.t(), list(String.t())}
  defp do_normalize(error, stacktrace) do
    exception = Exception.normalize(:error, error, stacktrace)
    {exception, stacktrace}
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

  defp stacktrace?(stacktrace) when is_list(stacktrace) do
    Enum.all?(stacktrace, &stacktrace_line?/1)
  end

  defp stacktrace?(_), do: false

  defp stacktrace_line?({_, _, _, [file: _, line: _]}), do: true
  defp stacktrace_line?(_), do: false
end
