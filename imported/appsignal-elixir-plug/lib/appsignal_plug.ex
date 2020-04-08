defmodule Appsignal.Plug do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc """
  AppSignal's Plug instrumentation instruments calls to Plug applications to
  gain performance insights and error reporting.

  ## Installation

  To install Appsignal.Plug into your Plug application, `use Appsignal.Plug` in
  your application's router module:

      defmodule AppsignalPlugExample do
        use Plug.Router
        use Appsignal.Plug

        plug(:match)
        plug(:dispatch)

        get "/" do
          send_resp(conn, 200, "Welcome")
        end
      end
  """

  defmacro __using__(_) do
    quote do
      @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
      @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

      use Plug.ErrorHandler

      def call(conn, opts) do
        span = @tracer.create_span("web")

        try do
          conn = super(conn, opts)
        rescue
          reason ->
            span
            |> Appsignal.Plug.handle_error(reason)
            |> @tracer.close_span()

            @tracer.ignore()

            reraise(reason, __STACKTRACE__)
        else
          conn ->
            span
            |> Appsignal.Plug.set_name(conn)
            |> Appsignal.Plug.set_params(conn)
            |> @tracer.close_span()
        end
      end
    end
  end

  def set_name(span, %Plug.Conn{method: method, private: %{plug_route: {path, _fun}}}) do
    @span.set_name(span, "#{method} #{path}")
  end

  def set_name(span, _conn) do
    span
  end

  def set_params(span, conn) do
    %Plug.Conn{params: params} = Plug.Conn.fetch_query_params(conn)
    @span.set_sample_data(span, "params", params)
  end

  def handle_error(span, %Plug.Conn.WrapperError{reason: %{plug_status: status}})
      when status < 500 do
    span
  end

  def handle_error(span, %Plug.Conn.WrapperError{conn: conn, reason: wrapped_reason, stack: stack}) do
    span
    |> @span.add_error(wrapped_reason, stack)
    |> Appsignal.Plug.set_name(conn)
    |> Appsignal.Plug.set_params(conn)
  end
end
