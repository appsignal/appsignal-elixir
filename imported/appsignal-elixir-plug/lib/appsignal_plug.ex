defmodule Appsignal.Plug do
  import Plug.Conn, only: [register_before_send: 2]
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)

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
      @tracer.close_span(span)
      conn
    end)
  end
end
