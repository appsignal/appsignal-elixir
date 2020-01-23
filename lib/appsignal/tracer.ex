defmodule Appsignal.Tracer do
  @doc """
  Creates a new span.
  """
  @spec create_span(String.t()) :: Appsignal.Span.t()
  def create_span(_name) do
    %Appsignal.Span{}
  end
end
