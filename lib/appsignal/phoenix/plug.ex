if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """

    @behaviour Plug
    import Plug.Conn, only: [register_before_send: 2, assign: 3]

    alias Appsignal.Transaction

    def init(opts), do: opts

    def call(conn, _config) do
      id = Logger.metadata()[:request_id] || Transaction.generate_id()
      transaction = Transaction.start(id, :http_request)

      conn |> assign(:appsignal_transaction, transaction)
    end
  end
end
