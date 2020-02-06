defmodule Appsignal.Error.Backend do
  @behaviour :gen_event

  def init(opts), do: {:ok, opts}
end
