if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.Phoenix.Router do
    @moduledoc false
    use Phoenix.Router

    @dialyzer {:nowarn_function, raising: 2}

    pipeline :browser do
      plug(:accepts, ["html"])
      plug(:fetch_session)
    end

    pipeline :halting do
      plug(:halt_unauthorized)
    end

    pipeline :halting_without_response do
      plug(:halt_without_response)
    end

    pipeline :raising do
      plug(:raise_in_pipeline)
    end

    pipeline :csrf do
      plug(Plug.CSRFProtection)
    end

    scope "/", AppsignalTest.Phoenix do
      pipe_through(:browser)

      get("/", PageController, :index)
      get("/show", PageController, :show)
      get("/exception", PageController, :exception)
      get("/only_one", PageController, :only_one)
      get("/render_in_instrument", PageController, :render_in_instrument)
      get("/redirect_in_instrument", PageController, :redirect_in_instrument)
      get("/broken_template", PageController, :broken_template)
      get("/chunked", PageController, :chunked)
      get("/decorated", PageController, :decorated)
      get("/nested_root", PageController, :nested_root)
      get("/ignored", PageController, :ignored)
      get("/task_exception", PageController, :task_exception)
      get("/exit", PageController, :exits)
      get("/throw", PageController, :throws)
      get("/bad_request", PageController, :bad_request)
      get("/leak", PageController, :leak)
      get("/users/:id", PageController, :index)
    end

    scope "/halted", AppsignalTest.Phoenix do
      pipe_through(:halting)
      get("/", PageController, :index)
    end

    scope "/halted_without_response", AppsignalTest.Phoenix do
      pipe_through(:halting_without_response)
      get("/", PageController, :index)
    end

    scope "/raise_in_pipeline", AppsignalTest.Phoenix do
      pipe_through(:raising)
      get("/", PageController, :index)
    end

    scope "/csrf", AppsignalTest.Phoenix do
      pipe_through([:browser, :csrf])
      post("/", PageController, :index)
    end

    forward("/forwarded_to_plug", AppsignalTest.Phoenix.ForwardedPlugRouter)
    forward("/forwarded_to_phoenix", AppsignalTest.Phoenix.ForwardedPhoenixRouter)

    defp halt_unauthorized(conn, _opts) do
      conn
      |> Plug.Conn.send_resp(401, "Unauthorized")
      |> Plug.Conn.halt()
    end

    defp halt_without_response(conn, _opts), do: Plug.Conn.halt(conn)

    defp raise_in_pipeline(_conn, _opts), do: raise("Exception in a pipeline!")
  end

  defmodule AppsignalTest.Phoenix.ForwardedPlugRouter do
    @moduledoc false
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get "/" do
      send_resp(conn, 200, "Forwarded to Plug")
    end
  end

  defmodule AppsignalTest.Phoenix.ForwardedPhoenixRouter do
    @moduledoc false
    use Phoenix.Router

    get("/", AppsignalTest.Phoenix.PageController, :index)
  end
end
