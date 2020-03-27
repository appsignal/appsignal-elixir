defmodule Appsignal.Plug do
  import Plug.Conn, only: [register_before_send: 2]
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
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

      plug(Appsignal.Plug)
      use Plug.ErrorHandler

      def handle_errors(_conn, %{kind: _kind, reason: %{plug_status: status}})
          when status < 500 do
        @tracer.ignore()
      end

      def handle_errors(conn, %{kind: _kind, reason: reason, stack: stack}) do
        conn = Plug.Conn.fetch_query_params(conn)

        @tracer.current_span()
        |> Appsignal.Plug.set_name(conn)
        |> Appsignal.Plug.set_params(conn)
        |> @span.add_error(reason, stack)
        |> @tracer.close_span()

        @tracer.ignore()
      end
    end
  end

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    span = @tracer.create_span("unknown")

    register_before_send(conn, fn conn ->
      conn = Plug.Conn.fetch_query_params(conn)

      span
      |> set_name(conn)
      |> set_params(conn)
      |> @tracer.close_span()

      conn
    end)
  end

  def set_name(span, %Plug.Conn{method: method, private: %{plug_route: {path, _fun}}}) do
    @span.set_name(span, "#{method} #{path}")
  end

  def set_name(span, _conn), do: span

  def set_params(span, conn) do
    %Plug.Conn{params: params} = Plug.Conn.fetch_query_params(conn)
    @span.set_sample_data(span, "params", params)
  end
end
