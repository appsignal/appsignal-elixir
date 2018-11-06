defmodule Appsignal.Backtrace do
  @doc ~S"""
  Parses the given stacktrace into a backtrace list.
  """
  def from_stacktrace(stacktrace) do
    Enum.map(stacktrace, &format_stacktrace_entry/1)
  end

  defp format_stacktrace_entry(entry) when is_binary(entry), do: entry

  defp format_stacktrace_entry({module, function, arity, location}) when is_list(arity) do
    format_stacktrace_entry({module, function, length(arity), location})
  end

  defp format_stacktrace_entry(entry) do
    Exception.format_stacktrace_entry(entry)
  end
end
