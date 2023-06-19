defmodule Appsignal.Utils.Literal do
  defstruct [:value]
end

defimpl Inspect, for: Appsignal.Utils.Literal do
  def inspect(%Appsignal.Utils.Literal{value: value}, _opts), do: value
end

defmodule Appsignal.Utils.ArgumentCleaner do
  @maximum_iterable_count 4
  @maximum_recursion 2

  def clean_literal(argument), do: %Appsignal.Utils.Literal{value: clean(argument)}
  def clean(argument), do: clean(argument, @maximum_recursion)

  def clean(argument, _) when is_nil(argument), do: inspect(argument)
  def clean(argument, _) when is_atom(argument), do: inspect(argument)
  def clean(argument, _) when is_binary(argument), do: "\"...\""
  def clean(argument, _) when is_bitstring(argument), do: "<<...>>"

  def clean(argument, recurse) when is_map(argument) do
    {struct, map} = Map.pop(argument, :__struct__)

    contents = if Enum.empty?(map), do: "", else: do_clean_map(map, recurse, struct)

    if struct do
      "%#{Appsignal.Utils.module_name(struct)}{#{contents}}"
    else
      "%{#{contents}}"
    end
  end

  def clean(argument, _) when is_integer(argument), do: "integer()"

  def clean(argument, _) when is_float(argument), do: "float()"

  def clean(argument, _) when is_pid(argument), do: "#PID<...>"

  def clean(argument, _) when is_port(argument), do: "#Port<...>"

  def clean(argument, _) when is_reference(argument), do: "#Reference<...>"

  def clean(argument, _) when is_function(argument) do
    inspected_function = inspect(argument)

    if String.starts_with?(inspected_function, "#Function<") do
      # Represent the function as `fn _, _ -> ... end`, as this allows
      # to express the arity clearly while redacting the rest.
      arity = :erlang.fun_info(argument)[:arity]

      ["fn", placeholders(arity), "-> ... end"]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")
    else
      # As it is not an anonymous function, calling `inspect` on it already
      # expresses it in the Module.function/arity form, which is fine.
      inspected_function
    end
  end

  def clean({}, _), do: "{}"

  def clean(argument, recurse) when is_tuple(argument) do
    "{#{do_clean_tuple(argument, recurse)}}"
  end

  def clean([], _), do: "[]"

  def clean(argument, recurse) when is_list(argument) do
    "[#{do_clean_list(argument, recurse)}]"
  end

  def clean(_, _), do: "any()"

  defp do_clean_tuple(_, 0), do: "..."

  defp do_clean_tuple(tuple, recurse) do
    tuple_list = Tuple.to_list(tuple)

    if Enum.count(tuple_list) <= @maximum_iterable_count do
      Enum.map_join(tuple_list, ", ", &clean(&1, recurse - 1))
    else
      "..."
    end
  end

  defp do_clean_list(list, @maximum_recursion) do
    # If it's a small keyword list (often used for options as the last argument)
    # keep the keys and clean the values. Otherwise, redact all values.
    if Enum.count(list) <= @maximum_iterable_count and Keyword.keyword?(list) do
      Enum.map_join(list, ", ", fn {key, value} ->
        "#{to_string(key)}: #{clean(value, @maximum_recursion - 1)}"
      end)
    else
      "..."
    end
  end

  defp do_clean_list(_, _), do: "..."

  defp do_clean_map(_, 0, _), do: "..."

  defp do_clean_map(map, recurse, nil) do
    # Only print cleaned keys and values for small maps that are not structs.
    # Otherwise, omit all keys and values.
    if Enum.count(map) <= @maximum_iterable_count do
      has_atom_keys = Enum.all?(map, fn {key, _} -> is_atom(key) end)

      separator = if has_atom_keys, do: ": ", else: " => "

      map
      |> Enum.sort(fn {key_a, _}, {key_b, _} -> key_a <= key_b end)
      |> Enum.map_join(", ", fn {key, value} ->
        clean_key = if has_atom_keys, do: to_string(key), else: clean(key, recurse - 1)

        "#{clean_key}#{separator}#{clean(value, recurse - 1)}"
      end)
    else
      "..."
    end
  end

  defp do_clean_map(_, _, _), do: "..."

  defp placeholders(0), do: nil

  defp placeholders(arity) do
    Enum.map_join(1..arity, ", ", fn _ -> "_" end)
  end
end
