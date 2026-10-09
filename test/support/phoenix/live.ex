if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.Phoenix.CounterComponent do
    @moduledoc false
    use Phoenix.LiveComponent

    def mount(socket), do: {:ok, assign(socket, count: 0)}

    def handle_event("increment", _params, socket) do
      {:noreply, update(socket, :count, &(&1 + 1))}
    end

    def handle_event("raise", _params, _socket) do
      raise "Exception in the component!"
    end

    def render(assigns) do
      ~H"""
      <div id={@id}>
        Component: <%= @count %>
        <button id="component-increment" phx-click="increment" phx-target={@myself}>+</button>
        <button id="component-raise" phx-click="raise" phx-target={@myself}>!</button>
      </div>
      """
    end
  end

  defmodule AppsignalTest.Phoenix.CounterLive do
    @moduledoc false
    use Phoenix.LiveView

    def mount(_params, _session, socket), do: {:ok, assign(socket, count: 0)}

    def handle_params(_params, _uri, socket), do: {:noreply, socket}

    def handle_event("increment", _params, socket) do
      {:noreply, update(socket, :count, &(&1 + 1))}
    end

    def handle_event("raise", _params, _socket) do
      raise "Exception in the LiveView!"
    end

    def render(assigns) do
      ~H"""
      <div>
        Count: <%= @count %>
        <button phx-click="increment">+</button>
        <.live_component module={AppsignalTest.Phoenix.CounterComponent} id="component" />
      </div>
      """
    end
  end

  # The same LiveView, instrumented by hand with the helpers applications used
  # before the automatic LiveView instrumentation existed, and without them.
  for {module, instrumented?} <- [
        {AppsignalTest.Phoenix.ManualLive, true},
        {AppsignalTest.Phoenix.UninstrumentedLive, false}
      ] do
    defmodule module do
      @moduledoc false
      use Phoenix.LiveView

      def mount(params, _session, socket) do
        instrument("mount", params, socket, fn -> {:ok, assign(socket, count: 0)} end)
      end

      def handle_event("increment", params, socket) do
        instrument("handle_event", params, socket, fn ->
          {:noreply, update(socket, :count, &(&1 + 1))}
        end)
      end

      def handle_event("raise", params, socket) do
        instrument("handle_event", params, socket, fn ->
          raise "Exception in the LiveView!"
        end)
      end

      def render(assigns) do
        ~H"""
        <div>Count: <%= @count %></div>
        """
      end

      if instrumented? do
        defp instrument(name, params, socket, fun) do
          Appsignal.Phoenix.LiveView.instrument(__MODULE__, name, params, socket, fun)
        end
      else
        defp instrument(_name, _params, _socket, fun), do: fun.()
      end
    end
  end
end
