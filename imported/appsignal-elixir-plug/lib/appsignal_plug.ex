defmodule Appsignal.Plug do
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
    @tracer.create_span("")
    conn
  end
end
