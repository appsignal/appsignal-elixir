defmodule Appsignal.Plug do
  import Plug.Conn, only: [register_before_send: 2]
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  defmacro __using__(_) do
    quote do
      plug(Appsignal.Plug)
    end
  end

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    span = @tracer.create_span("unknown")

    register_before_send(conn, fn conn ->
      span
      |> set_name(conn)
      |> @tracer.close_span()

      conn
    end)
  end

  defp set_name(span, %Plug.Conn{method: method, private: %{plug_route: {path, _fun}}} = conn) do
    @span.set_name(span, "#{method} #{path}")
  end
end
