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
          super(conn, opts)
        catch
          type, reason ->
            span
            |> Appsignal.Plug.handle_error(type, reason)
            |> @tracer.close_span()

            @tracer.ignore()

            reraise(reason, __STACKTRACE__)
        else
          conn ->
            span
            |> Appsignal.Plug.set_name(conn)
            |> Appsignal.Plug.set_params(conn)
            |> @tracer.close_span()

            conn
        end
      end

      defoverridable call: 2
    end
  end

  def put_name(%Plug.Conn{} = conn, name) do
    Plug.Conn.put_private(conn, :appsignal_name, name)
  end

  def set_name(span, %Plug.Conn{private: %{appsignal_name: name}}) do
    @span.set_name(span, name)
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

  def handle_error(span, :error, %Plug.Conn.WrapperError{reason: %{plug_status: status}})
      when status < 500 do
    span
  end

  def handle_error(span, :error, %Plug.Conn.WrapperError{
        conn: conn,
        reason: wrapped_reason,
        stack: stack
      }) do
    span
    |> @span.add_error(:error, wrapped_reason, stack)
    |> Appsignal.Plug.set_name(conn)
    |> Appsignal.Plug.set_params(conn)
  end
end
