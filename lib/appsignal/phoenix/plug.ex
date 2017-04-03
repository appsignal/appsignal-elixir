if Appsignal.plug? do
  defmodule Appsignal.Phoenix.Plug do

    defmacro __using__(_) do
      IO.warn "Appsignal.Phoenix.Plug is deprecated. Use Appsignal.Plug instead."
      quote do
        use Appsignal.Plug
      end
    end

    def extract_error_metadata(reason, conn, stack) do
      IO.warn "Appsignal.Phoenix.Plug.extract_error_metadata/3 is deprecated. Use Appsignal.Plug.extract_error_metadata/3 instead."
      Appsignal.Plug.extract_error_metadata(reason, conn, stack)
    end
  end
end
