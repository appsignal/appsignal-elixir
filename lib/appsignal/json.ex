defmodule Json do
  defdelegate encode(input), to: Jason
  defdelegate encode!(input), to: Jason
  defdelegate decode(input), to: Jason
  defdelegate decode!(input), to: Jason
end
