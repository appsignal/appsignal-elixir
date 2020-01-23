defmodule Appsignal.Tracer do
  alias Appsignal.{Span, Nif}

  @doc """
  Creates a new span.
  """
  @spec create_span(String.t()) :: Span.t()
  def create_span(name) do
    {:ok, reference} = Nif.create_root_span(name)
    %Span{reference: reference}
  end
end
