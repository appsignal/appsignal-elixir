defmodule Appsignal.Utils.Type do
  defstruct [:type]

  def from(term) do
    %__MODULE__{type: of(term)}
  end

  def of(term) when is_boolean(term), do: "boolean"

  def of(nil), do: "nil"

  def of(term) when is_integer(term), do: "integer"

  def of(term) when is_float(term), do: "float"

  def of(term) when is_pid(term), do: "pid"

  def of(term) when is_atom(term), do: "atom"

  def of(term) when is_bitstring(term) and not is_binary(term), do: "bitstring"

  def of(term) when is_binary(term), do: "binary"

  def of(term) when is_function(term), do: "function"

  def of(term) when is_binary(term), do: "binary"

  def of(term) when is_function(term), do: "function"

  def of(term) when is_port(term), do: "port"

  def of(term) when is_reference(term), do: "reference"

  def of(term) when is_tuple(term) do
    "{#{Enum.map_join(Tuple.to_list(term), ", ", &of/1)}}"
  end

  def of(term) when is_list(term) do
    "[#{Enum.map_join(term, ", ", &of/1)}]"
  end

  def of(term) when is_map(term) do
    {struct, map} = Map.pop(term, :__struct__)

    "%#{Appsignal.Utils.module_name(struct)}{#{Enum.map_join(map, ", ", fn {key, value} -> "#{of(key)} => #{of(value)}" end)}}"
  end

  def of(_term), do: "unknown"
end

defimpl Inspect, for: Appsignal.Utils.Type do
  def inspect(%Appsignal.Utils.Type{type: type}, _opts), do: type
end
