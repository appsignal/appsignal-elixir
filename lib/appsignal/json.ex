defmodule Json do
  if(!Code.ensure_loaded?(Jason) && Code.ensure_loaded?(Poison)) do
    @json Poison
  else
    @json Jason
  end

  defdelegate encode(input), to: @json
  defdelegate encode!(input), to: @json
  defdelegate decode(input), to: @json
  defdelegate decode!(input), to: @json
end
