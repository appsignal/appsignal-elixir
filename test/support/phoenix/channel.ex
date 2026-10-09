if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.Phoenix.RoomChannel do
    @moduledoc false
    use Phoenix.Channel

    def join("room:" <> _room, _params, socket), do: {:ok, socket}

    def handle_in("ping", params, socket) do
      Appsignal.Phoenix.Channel.instrument(__MODULE__, "ping", params, socket, fn ->
        {:reply, {:ok, %{"pong" => params["body"]}}, socket}
      end)
    end

    def handle_in("shout", params, socket) do
      Appsignal.Phoenix.Channel.instrument(__MODULE__, "shout", params, socket, fn ->
        broadcast!(socket, "shout", params)
        {:noreply, socket}
      end)
    end

    def handle_in("raise", params, socket) do
      Appsignal.Phoenix.Channel.instrument(__MODULE__, "raise", params, socket, fn ->
        raise "Exception in the channel!"
      end)
    end

    def handle_in("no_params", _params, socket) do
      Appsignal.Phoenix.Channel.instrument(__MODULE__, "no_params", socket, fn ->
        {:noreply, socket}
      end)
    end
  end

  defmodule AppsignalTest.Phoenix.UserSocket do
    @moduledoc false
    use Phoenix.Socket

    channel("room:*", AppsignalTest.Phoenix.RoomChannel)

    def connect(_params, socket, _connect_info), do: {:ok, socket}
    def id(_socket), do: nil
  end
end
