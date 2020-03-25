defmodule Appsignal.Phoenix do
  defmacro __using__(_) do
    quote do
      @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
      @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

      def call(conn, opts) do
        super(conn, opts)
      rescue
        reason -> handle_error(reason)
      end

      defp handle_error(%Plug.Conn.WrapperError{reason: reason, stack: stack}) do
        @tracer.current_span()
        |> @span.add_error(reason, stack)

        reraise(reason, stack)
      end
    end
  end
end
