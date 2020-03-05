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
  alias Appsignal.{Span, Test.Tracer}

  setup do
    Tracer.start_link()
    :ok
  end

  setup do
    :get
    |> conn("/")
    |> PlugWithAppsignal.call([])

    :ok
  end

  test "creates a root span" do
    assert Tracer.get(:create_span) == [{"unknown"}]
  end

  test "closes the span" do
    assert [{%Span{}}] = Tracer.get(:close_span)
  end
end
