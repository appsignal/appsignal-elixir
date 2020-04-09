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
          kind, reason ->
            stack = __STACKTRACE__

            span
            |> Appsignal.Plug.handle_error(kind, reason, stack, conn)
            |> @tracer.close_span()

            @tracer.ignore()

            :erlang.raise(kind, reason, stack)
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

  def handle_error(
        span,
        :error,
        %Plug.Conn.WrapperError{reason: %{plug_status: status}},
        _stack,
        _conn
      )
      when status < 500 do
    span
  end

  def handle_error(
        span,
        :error,
        %Plug.Conn.WrapperError{conn: conn, reason: wrapped_reason, stack: stack},
        _stack,
        _conn
      ) do
    handle_error(span, :error, wrapped_reason, stack, conn)
  end

  def handle_error(span, kind, reason, stack, conn) do
    span
    |> @span.add_error(kind, reason, stack)
    |> Appsignal.Plug.set_name(conn)
    |> Appsignal.Plug.set_params(conn)
  end
end
