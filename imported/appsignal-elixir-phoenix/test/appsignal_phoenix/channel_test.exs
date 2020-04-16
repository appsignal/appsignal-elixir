defmodule Appsignal.Phoenix.ChannelTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}

  setup do
    Test.Tracer.start_link()
    Test.Span.start_link()

    %{return: PhoenixWeb.Channel.handle_in("new_msg", %{}, %Phoenix.Socket{})}
  end

  test "calls the passed function, and returns its return", %{return: return} do
    assert {:noreply, %Phoenix.Socket{}} = return
  end

  test "creates a root span" do
    assert Test.Tracer.get(:create_span) == {:ok, [{"http_request", nil}]}
  end

  test "sets the span's name" do
    assert {:ok, [{%Span{}, "PhoenixWeb.Channel#new_msg"}]} = Test.Span.get(:set_name)
  end

  test "closes the span" do
    assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
  end
end
