if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.Phoenix.PageHTML do
    @moduledoc false
    use Phoenix.Component

    def show(assigns) do
      ~H"""
      <p>Hello, <%= @name %>!</p>
      """
    end

    def broken(assigns) do
      ~H"""
      <p><%= String.to_integer(@number) %></p>
      """
    end
  end

  defmodule AppsignalTest.Phoenix.ErrorHTML do
    @moduledoc false
    def render(template, _assigns), do: Phoenix.Controller.status_message_from_template(template)
  end

  defmodule AppsignalTest.Phoenix.PageController do
    @moduledoc false
    use Phoenix.Controller, formats: [:html]
    use Appsignal.Instrumentation.Decorators
    import Plug.Conn

    # Phoenix 1.7 controllers render inside an `app` layout unless told not
    # to. Phoenix 1.8 dropped the default.
    if Appsignal.Dependencies.match?(:phoenix, "< 1.8.0") do
      plug(:put_layout, false)
    end

    def index(conn, _params) do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, "Welcome to Phoenix!")
    end

    def show(conn, params) do
      render(conn, :show, name: params["name"] || "World")
    end

    def exception(_conn, _params) do
      raise "Exception!"
    end

    def only_one(conn, %{"id" => "1"}) do
      send_resp(conn, 200, "One")
    end

    def render_in_instrument(conn, _params) do
      Appsignal.instrument("event.group", fn ->
        render(conn, :show, name: "instrumented")
      end)
    end

    def redirect_in_instrument(conn, _params) do
      Appsignal.instrument("event.group", fn ->
        redirect(conn, to: "/")
      end)
    end

    def broken_template(conn, _params) do
      render(conn, :broken, number: "one")
    end

    def chunked(conn, _params) do
      conn = send_chunked(conn, 200)
      send(self(), {:streaming, AppsignalTest.Spans.spans()})
      {:ok, conn} = chunk(conn, "Hello, ")
      {:ok, conn} = chunk(conn, "chunks!")
      conn
    end

    @decorate transaction_event()
    def decorated(conn, _params) do
      render(conn, :show, name: "decorated")
    end

    @decorate transaction()
    def nested_root(conn, _params) do
      render(conn, :show, name: "nested")
    end

    def task_exception(conn, _params) do
      Task.await(Task.async(fn -> raise "Exception in a task!" end))
      send_resp(conn, 200, "Unreachable")
    end

    def exits(_conn, _params), do: exit(:exited)

    def throws(_conn, _params), do: throw(:thrown)

    def bad_request(_conn, _params), do: raise(Plug.BadRequestError)

    def leak(conn, _params) do
      Appsignal.Tracer.create_span("leaked", Appsignal.Tracer.current_span())
      send_resp(conn, 200, "Leaked!")
    end

    def ignored(conn, _params) do
      Appsignal.Tracer.ignore()
      render(conn, :show, name: "ignored")
    end
  end
end
