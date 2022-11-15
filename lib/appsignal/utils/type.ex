defmodule Appsignal.Utils.Type do
  defstruct [:type]

  def from(term) do
    %__MODULE__{type: of(term)}
  end

  defp of(term) when is_boolean(term), do: "boolean"

  defp of(nil), do: "nil"

  defp of(term) when is_integer(term), do: "integer"

  defp of(term) when is_float(term), do: "float"

  defp of(term) when is_pid(term), do: "pid"

  defp of(term) when is_atom(term), do: "atom"

  defp of(term) when is_bitstring(term) and not is_binary(term), do: "bitstring"

  defp of(term) when is_binary(term), do: "binary"

  defp of(term) when is_function(term), do: "function"

  defp of(term) when is_port(term), do: "port"

  defp of(term) when is_reference(term), do: "reference"

  defp of(term) when is_tuple(term) do
    "{#{Enum.map_join(Tuple.to_list(term), ", ", &of/1)}}"
  end

  defp of(term) when is_list(term) do
    "[#{Enum.map_join(term, ", ", &of/1)}]"
  end

  defp of(term) when is_map(term) do
    {struct, map} = Map.pop(term, :__struct__)

    "%#{Appsignal.Utils.module_name(struct)}{#{Enum.map_join(map, ", ", fn {key, value} -> "#{of(key)} => #{of(value)}" end)}}"
  end

  defp of(_term), do: "unknown"
end

defimpl Inspect, for: Appsignal.Utils.Type do
  def inspect(%Appsignal.Utils.Type{type: type}, _opts), do: type
end

defimpl String.Chars, for: Appsignal.Utils.Type do
  def to_string(%Appsignal.Utils.Type{type: type}), do: type
end
