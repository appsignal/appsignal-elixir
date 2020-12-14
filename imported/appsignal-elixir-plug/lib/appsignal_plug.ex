defmodule Appsignal.Plug do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)
  import Appsignal.Utils, only: [module_name: 1]

  @moduledoc """
  AppSignal's Plug instrumentation instruments calls to Plug applications to
  gain performance insights and error reporting.

  ## Installation

  To install `Appsignal.Plug` into your Plug application, `use Appsignal.Plug`
  in your application's router module:

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

  @doc false
  defmacro __using__(_) do
    quote do
      require Logger
      Logger.debug("AppSignal.Plug attached to #{__MODULE__}")

      @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
      @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

      use Plug.ErrorHandler

      def call(%Plug.Conn{private: %{appsignal_plug_instrumented: true}} = conn, opts) do
        Logger.warn(
          "Appsignal.Plug was included twice, disabling Appsignal.Plug. Please only `use Appsignal.Plug` once."
        )

        super(conn, opts)
      end

      def call(conn, opts) do
        Appsignal.instrument(fn span ->
          _ = @span.set_namespace(span, "http_request")

          try do
            super(conn, opts)
          catch
            kind, reason ->
              stack = __STACKTRACE__

              _ =
                span
                |> Appsignal.Plug.handle_error(kind, reason, stack, conn)
                |> @tracer.close_span()

              @tracer.ignore()
              :erlang.raise(kind, reason, stack)
          else
            conn ->
              _ = Appsignal.Plug.set_conn_data(span, conn)
              Plug.Conn.put_private(conn, :appsignal_plug_instrumented, true)
          end
        end)
      end

      defoverridable call: 2
    end
  end

  @doc """
  Adds an `:appsignal_name` to the `Plug.Conn`, to overwrite the root
  `Appsignal.Span`'s name.

  ## Examples

      iex> Appsignal.Plug.put_name(%Plug.Conn{}, "AppsignalPlugExample#index")
      %Plug.Conn{private: %{appsignal_name: "AppsignalPlugExample#index"}}

  In a Plug app, call `Appsignal.Plug.put_name/2` on the returned `Plug.Conn`
  struct:

      defmodule AppsignalPlugExample do
        use Plug.Router
        use Appsignal.Plug

        plug(:match)
        plug(:dispatch)

        get "/" do
          conn
          |> Appsignal.Plug.put_name("AppsignalPlugExample#index")
          |> send_resp(200, "Welcome")
        end
      end
  """
  def put_name(%Plug.Conn{} = conn, name) do
    Plug.Conn.put_private(conn, :appsignal_name, name)
  end

  @doc false
  def set_conn_data(span, conn) do
    span
    |> set_name(conn)
    |> set_category(conn)
    |> set_params(conn)
    |> set_sample_data(conn)
    |> set_session_data(conn)
  end

  @doc false
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

  @doc false
  def handle_error(
        span,
        :error,
        %Plug.Conn.WrapperError{conn: conn, reason: wrapped_reason, stack: stack},
        _stack,
        _conn
      ) do
    handle_error(span, :error, wrapped_reason, stack, conn)
  end

  @doc false
  def handle_error(span, kind, reason, stack, conn) do
    conn_with_status = Plug.Conn.put_status(conn, Plug.Exception.status(reason))

    span
    |> @span.add_error(kind, reason, stack)
    |> set_conn_data(conn_with_status)
  end

  defp set_name(span, %Plug.Conn{private: %{appsignal_name: name}}) do
    @span.set_name(span, name)
  end

  defp set_name(span, %Plug.Conn{
         private: %{phoenix_action: action, phoenix_controller: controller}
       }) do
    @span.set_name(span, "#{module_name(controller)}##{action}")
  end

  defp set_name(span, %Plug.Conn{method: method, private: %{plug_route: {path, _fun}}}) do
    @span.set_name(span, "#{method} #{path}")
  end

  defp set_name(span, _conn) do
    span
  end

  defp set_category(span, %Plug.Conn{private: %{phoenix_endpoint: _endpoint}}) do
    @span.set_attribute(span, "appsignal:category", "call.phoenix")
  end

  defp set_category(span, _conn) do
    @span.set_attribute(span, "appsignal:category", "call.plug")
  end

  defp set_params(span, conn) do
    %Plug.Conn{params: params} = Plug.Conn.fetch_query_params(conn)
    @span.set_sample_data(span, "params", params)
  end

  defp set_sample_data(span, conn) do
    @span.set_sample_data(span, "environment", Appsignal.Metadata.metadata(conn))
  end

  defp set_session_data(span, conn) do
    set_session_data(span, Application.get_env(:appsignal, :config), conn)
  end

  defp set_session_data(span, %{skip_session_data: false}, %Plug.Conn{
         private: %{plug_session: session, plug_session_fetch: :done}
       }) do
    @span.set_sample_data(span, "session_data", session)
  end

  defp set_session_data(span, _config, _conn) do
    span
  end
end
