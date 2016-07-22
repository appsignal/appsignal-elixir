defmodule Appsignal.Plug do
  @moduledoc """
  Plug for instrumentation of Phoenix requests

  To integrate Appsignal with Phoenix, add the `Appsignal.Plug` to
  your `endpoint.ex` file, just before your router:

  ```
  plug Appsignal.Plug
  ```
  """

  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2, assign: 3]

  require Logger

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
        collect_sample_data(transaction, conn)
      end

      :ok = Transaction.complete(transaction)

      conn
    end)
    |> assign(:appsignal_transaction, transaction)
  end

  defp collect_sample_data(transaction, conn) do
    # collect sample data
    transaction
    |> Transaction.set_sample_data("params", conn.params)
  end
end
