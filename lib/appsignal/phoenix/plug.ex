if Appsignal.plug?() do
  defmodule Appsignal.Phoenix.Plug do
    defmacro __using__(_) do
      IO.warn("Appsignal.Phoenix.Plug is deprecated. Use Appsignal.Plug instead.")

      quote do
        use Appsignal.Plug
      end
    end

    @deprecated "Use Appsignal.Error.metadata/1 instead."
    def extract_error_metadata(reason, conn, stack) do
      {reason, message, _} = Appsignal.Error.metadata(reason, [])
      {reason, message, stack, conn}
    end
  end
end
