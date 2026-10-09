if Appsignal.Dependencies.present?(:phoenix) do
  defmodule Appsignal.Phoenix.ChannelTest do
    use AppsignalTest.IntegrationCase
    import Phoenix.ChannelTest

    @endpoint AppsignalTest.Phoenix.Endpoint

    setup do
      start_supervised!({Phoenix.PubSub, name: AppsignalTest.Phoenix.PubSub})
      start_supervised!(@endpoint)

      {:ok, _reply, socket} =
        AppsignalTest.Phoenix.UserSocket
        |> socket(nil, %{})
        |> subscribe_and_join(AppsignalTest.Phoenix.RoomChannel, "room:lobby")

      [socket: socket]
    end

    describe "handling a message through a channel" do
      test "replies as the handler does", %{socket: socket} do
        ref = push(socket, "ping", %{"body" => "hi"})
        assert_reply(ref, :ok, %{"pong" => "hi"})
      end

      test "broadcasts as the handler does", %{socket: socket} do
        push(socket, "shout", %{"body" => "hey"})
        assert_broadcast("shout", %{"body" => "hey"})
        await_spans()
      end

      test "crashes the channel with the handler's error", %{socket: socket} do
        Process.flag(:trap_exit, true)
        push(socket, "raise", %{"body" => "boom"})

        assert_receive {:EXIT, _pid, {%RuntimeError{message: "Exception in the channel!"}, _}}
      end
    end

    describe "the span recorded for a message" do
      test "is a root span named after the channel and event", %{socket: socket} do
        ref = push(socket, "ping", %{"body" => "hi"})
        assert_reply(ref, :ok, _)

        assert [span] = await_spans()
        assert span["name"] == "AppsignalTest.Phoenix.RoomChannel#ping"
        assert span["parent_span_id"] == ""
        assert span["attributes"]["appsignal.namespace"] == "channel"
        assert category(span) == "AppsignalTest.Phoenix.RoomChannel#ping"
      end

      test "has the message's parameters", %{socket: socket} do
        ref = push(socket, "ping", %{"body" => "hi"})
        assert_reply(ref, :ok, _)

        assert [span] = await_spans()
        assert span["sample_data"]["params"] == %{"body" => "hi"}
      end

      test "has the socket as its environment", %{socket: socket} do
        ref = push(socket, "ping", %{"body" => "hi"})
        assert_reply(ref, :ok, _)

        assert [%{"sample_data" => %{"environment" => environment}}] = await_spans()

        assert %{
                 "channel" => "Elixir.AppsignalTest.Phoenix.RoomChannel",
                 "endpoint" => "Elixir.AppsignalTest.Phoenix.Endpoint",
                 "handler" => "Elixir.AppsignalTest.Phoenix.UserSocket",
                 "topic" => "room:lobby"
               } = environment
      end

      test "is named after the channel and event for a message that broadcasts", %{
        socket: socket
      } do
        push(socket, "shout", %{"body" => "hey"})
        assert [%{"name" => "AppsignalTest.Phoenix.RoomChannel#shout"}] = await_spans()
      end

      test "has no parameters with instrument/4", %{socket: socket} do
        push(socket, "no_params", %{"ignored" => "yes"})

        assert [span] = await_spans(&match?([%{"closed" => true}], &1))
        assert span["name"] == "AppsignalTest.Phoenix.RoomChannel#no_params"
        assert span["sample_data"]["params"] == %{}
      end

      test "has the error when the handler raises", %{socket: socket} do
        Process.flag(:trap_exit, true)
        push(socket, "raise", %{"body" => "boom"})

        assert [span] = await_spans(&match?([%{"closed" => true}], &1))
        assert span["error"]["name"] == "RuntimeError"
        assert span["sample_data"]["params"] == %{"body" => "boom"}
      end
    end

    describe "channel events that record no span" do
      test "joining the channel" do
        assert spans() == []
      end
    end
  end
end
