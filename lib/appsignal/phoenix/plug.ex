if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """

    @behaviour Plug

    alias Appsignal.Transaction

    def init(opts), do: opts

    def call(conn, _config) do
      id = Logger.metadata()[:request_id] || Transaction.generate_id()
      Transaction.start(id, :http_request)
      conn
    end
  end
end
