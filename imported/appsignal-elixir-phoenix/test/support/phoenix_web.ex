defmodule PhoenixWeb.Router do
  use Phoenix.Router

  get("/", PhoenixWeb.Controller, :index)
  get("/exception", PhoenixWeb.Controller, :exception)
end

defmodule PhoenixWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_web
  use Appsignal.Phoenix

  plug(PhoenixWeb.Router)
end

defmodule PhoenixWeb.Controller do
  use Phoenix.Controller, namespace: PhoenixWeb
  import Plug.Conn

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "Welcome to Phoenix!")
  end

  def exception(_conn, _params) do
    raise "Exception!"
  end
end

defmodule PhoenixWeb.View do
  use Phoenix.View,
    root: "test/support",
    namespace: AppsignalPhoenixExampleWeb

  use Appsignal.Phoenix.View
end

defmodule PhoenixWeb.Channel do
  use Phoenix.Channel
  require Appsignal.Phoenix.Channel

  def join(_channel, _message, socket) do
    {:ok, socket}
  end

  def handle_in(name, %{"body" => "Exception!"} = params, socket) do
    Appsignal.Phoenix.Channel.instrument(__MODULE__, name, params, socket, fn ->
      raise "Exception!"
    end)
  end

  def handle_in(name, %{"body" => _} = params, socket) do
    Appsignal.Phoenix.Channel.instrument(__MODULE__, name, params, socket, fn ->
      {:noreply, socket}
    end)
  end

  def handle_in(name, _params, socket) do
    Appsignal.Phoenix.Channel.instrument(__MODULE__, name, socket, fn ->
      {:noreply, socket}
    end)
  end
end

defmodule PhoenixWeb.LiveView do
  use Phoenix.LiveView

  def mount(params, socket) when params == %{} do
    Appsignal.Phoenix.LiveView.instrument(__MODULE__, "mount", socket, fn ->
      {:ok, socket}
    end)
  end

  def mount(%{"body" => "Exception!"} = params, socket) do
    Appsignal.Phoenix.LiveView.instrument(__MODULE__, "mount", params, socket, fn ->
      raise "Exception!"
    end)
  end

  def mount(params, socket) do
    Appsignal.Phoenix.LiveView.instrument(__MODULE__, "mount", params, socket, fn ->
      {:ok, socket}
    end)
  end

  def render(assigns) do
    ~H"""
    Hello World
    """
  end
end

defmodule PhoenixWeb.ErrorView do
  def render(_layout, %{reason: reason}) do
    inspect(reason)
  end
end
