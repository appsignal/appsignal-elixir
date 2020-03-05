defmodule PlugWithAppsignal do
  use Plug.Router
  use Appsignal.Plug

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  use Plug.Test
  alias Appsignal.Test.Tracer

  setup do
    Tracer.start_link()
    :ok
  end

  test "creates a root span" do
    :get
    |> conn("/")
    |> PlugWithAppsignal.call([])

    assert Tracer.get(:create_span) == [{""}]
  end
end
