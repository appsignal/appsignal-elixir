defmodule Appsignal.Phoenix.Plug do
  @moduledoc """
  Plug handler for Phoenix requests
  """

  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2, assign: 3]

  alias Appsignal.Transaction
  alias Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _config) do
    id = Logger.metadata()[:request_id] || Transaction.generate_id()
    transaction = Transaction.start(id, :http_request)

    conn
    |> register_before_send(fn conn ->

      try do
        action_str = "#{Controller.controller_module(conn)}##{Controller.action_name(conn)}"
        <<"Elixir.", action :: binary>> = action_str
        Transaction.set_action(transaction, action)
      catch
        _, _ -> :ok
      end
      resp = Transaction.finish(transaction)

      if resp == :sample do
        Transaction.set_request_metadata(transaction, conn)
      end

      :ok = Transaction.complete(transaction)

      conn
    end)
    |> assign(:appsignal_transaction, transaction)
  end

end
