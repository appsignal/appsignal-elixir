defmodule Appsignal.Json.MissingEncoderError do
  defexception message: """
               No JSON encoder found. Please add jason to your list of dependencies in mix.exs:

                   def deps do
                     [
                       {:appsignal, "~> 1.0"},
                       {:jason, "~> 1.1"}
                     ]
                   end
               """
end

defmodule Appsignal.Json.MissingEncoder do
  def encode(input), do: {:error, :no_json_encoder}
  def encode!(_input), do: raise(%Appsignal.Json.MissingEncoderError{})
  def decode(input), do: {:error, :no_json_encoder}
  def decode!(_input), do: raise(%Appsignal.Json.MissingEncoderError{})
end

defmodule Appsignal.Json do
  cond do
    Code.ensure_loaded?(Jason) -> @json Jason
    Code.ensure_loaded?(Poison) -> @json Poison
    true -> @json Appsignal.Json.MissingEncoder
  end

  defdelegate encode(input), to: @json
  defdelegate encode!(input), to: @json
  defdelegate decode(input), to: @json
  defdelegate decode!(input), to: @json
end
