defmodule PhoenixWeb.Endpoint do
  use Phoenix.Controller
  use Appsignal.Phoenix

  def init(opts) do
    {:ok, opts}
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "Welcome to Phoenix!")
  end
end

defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  doctest Appsignal.Phoenix
  import Phoenix.ConnTest
  @endpoint PhoenixWeb.Endpoint

  setup do
    %{conn: get(build_conn(), "/")}
  end

  test "sends the response", %{conn: conn} do
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
