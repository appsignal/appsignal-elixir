defmodule Appsignal.Phoenix do
  defmacro __using__(_) do
    quote do
      use Appsignal.Plug
    end
  end
end
