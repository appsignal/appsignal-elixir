defmodule Appsignal.Plug do
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

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
      Appsignal.IntegrationLogger.debug("AppSignal.Plug attached to #{__MODULE__}")

      @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
      @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

      def call(%Plug.Conn{private: %{appsignal_plug_instrumented: true}} = conn, opts) do
        Logger.warning(
          "Appsignal.Plug was included twice, disabling Appsignal.Plug. Please only `use Appsignal.Plug` once."
        )

        super(conn, opts)
      end

      def call(conn, opts) do
        span = @tracer.create_span("http_request", @tracer.current_span)

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
            @tracer.close_span(span)

            _ = Appsignal.Plug.set_conn_data(span, conn)
            Plug.Conn.put_private(conn, :appsignal_plug_instrumented, true)
        end
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
    |> @span.set_name(Appsignal.Metadata.name(conn))
    |> @span.set_attribute("appsignal:category", Appsignal.Metadata.category(conn))
    |> @span.set_sample_data_if_nil("params", Appsignal.Metadata.params(conn))
    |> @span.set_sample_data_if_nil("environment", Appsignal.Metadata.metadata(conn))
    |> @span.set_sample_data_if_nil("session_data", Appsignal.Metadata.session(conn))
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
  def handle_error(span, _kind, %{plug_status: status}, _stack, _conn) when status < 500 do
    span
  end

  @doc false
  def handle_error(span, kind, reason, stack, conn) do
    conn_with_status = Plug.Conn.put_status(conn, Plug.Exception.status(reason))

    span
    |> @span.add_error(kind, reason, stack)
    |> set_conn_data(conn_with_status)
  end
end
