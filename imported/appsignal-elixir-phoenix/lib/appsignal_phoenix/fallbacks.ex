unless Code.ensure_loaded?(Appsignal.Phoenix.Instrumenter) do
  defmodule Appsignal.Phoenix.Instrumenter do
    @moduledoc false
  end
end
