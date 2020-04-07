defmodule Appsignal.Phoenix.EventHandlerTest do
  use ExUnit.Case
  alias Appsignal.{Phoenix, Span, Test}

  setup do
    Test.Span.start_link()
    :ok
  end

  test "is attached to the router_dispatch event" do
    assert attached?([:phoenix, :router_dispatch, :start])
  end

  describe "after receiving a router_dispatch-start event" do
    setup [:create_root_span, :router_dispatch_start_event]

    test "keeps the handler attached" do
      assert attached?([:phoenix, :router_dispatch, :start])
    end

    test "sets the transaction's action name" do
      assert [{%Span{}, "AppsignalPhoenixExampleWeb.PageController#index"}] =
               Test.Span.get!(:set_name)
    end
  end

  describe "after receiving a router_dispatch-start event with non-atom opts" do
    setup [:create_root_span]

    setup do: do_router_dispatch_start_event(atom?: false)

    test "keeps the handler attached" do
      assert attached?([:phoenix, :router_dispatch, :start])
    end

    test "does not set the transaction's action name" do
      assert Test.Span.get(:set_name) == :error
    end
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Phoenix.EventHandler, event}
    end)
  end

  defp create_root_span(_context) do
    [span: Appsignal.Tracer.create_span("root")]
  end

  defp router_dispatch_start_event(_context) do
    do_router_dispatch_start_event()
  end

  defp do_router_dispatch_start_event(plug_opts \\ :index) do
    :telemetry.execute(
      [:phoenix, :router_dispatch, :start],
      %{time: -576_460_736_044_040_000},
      %{
        conn: %Plug.Conn{},
        log: :debug,
        path_params: %{},
        pipe_through: [:browser],
        plug: AppsignalPhoenixExampleWeb.PageController,
        plug_opts: plug_opts,
        route: "/"
      }
    )
  end
end
