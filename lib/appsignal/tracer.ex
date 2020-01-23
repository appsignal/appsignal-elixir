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

  @doc """
  Returns the current span.
  """
  @spec current_span() :: Span.t() | nil
  def current_span do
    nil
  end
end
