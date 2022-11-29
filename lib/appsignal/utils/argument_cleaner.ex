defmodule Appsignal.Utils.ArgumentCleaner do
  alias Appsignal.Utils.Type

  def clean(argument)
      when is_boolean(argument) or is_integer(argument) or is_float(argument) or is_pid(argument) or
             is_port(argument) or is_reference(argument) do
    argument
  end

  def clean(argument) when is_map(argument) do
    {struct, map} = Map.pop(argument, :__struct__)

    "%#{Appsignal.Utils.module_name(struct)}{#{Enum.map_join(map, ", ", fn {key, value} -> "#{inspect(key)} => #{inspect(clean(value))}" end)}}"
  end

  def clean(argument), do: Type.from(argument)
end
