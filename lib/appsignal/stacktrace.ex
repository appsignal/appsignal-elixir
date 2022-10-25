defmodule ArgumentType do
  defstruct [:value, :type]

  def from_term(term) do
    %ArgumentType{value: term, type: typeof(term)}
  end

  for type <-
        ~w[boolean binary bitstring float function integer list map nil pid port reference tuple atom] do
    defp typeof(x) when unquote(:"is_#{type}")(x), do: unquote(type)
  end

  defp typeof(_), do: "unknown"
end

defimpl Inspect, for: ArgumentType do
  def inspect(%ArgumentType{type: type}, _opts), do: type
end

defmodule Appsignal.Stacktrace do
  @moduledoc false

  if Version.compare(System.version(), "1.7.0") == :lt do
    defmacro get do
      quote do
        :erlang.get_stacktrace()
      end
    end
  else
    defmacro get do
      quote do
        __STACKTRACE__
      end
    end
  end

  @doc ~S"""
  Parses the given stacktrace into a backtrace list.
  """
  def format(stacktrace) do
    Enum.map(stacktrace, &format_stacktrace_entry/1)
  end

  defp format_stacktrace_entry(entry) when is_binary(entry), do: entry

  defp format_stacktrace_entry({module, function, arguments, location}) when is_list(arguments) do
    Exception.format_stacktrace_entry({module, function, to_types(arguments), location})
  end

  defp format_stacktrace_entry(entry) do
    Exception.format_stacktrace_entry(entry)
  end

  defp to_types(arguments) do
    Enum.map(arguments, &ArgumentType.from_term/1)
  end
end
