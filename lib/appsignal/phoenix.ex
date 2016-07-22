defmodule Appsignal.Phoenix do
  @moduledoc """
  Instrumentation of Phoenix requests

  To integrate Appsignal with Phoenix, *use* the `Appsignal.Phoenix` module in
  your `endpoint.ex` file, just before your router:

  ```
  use Appsignal.Phoenix
  ```

  This will install a plug which measures request time, and also will
  trap common HTTP errors (like 4xx status codes).

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
        Transaction.set_request_metadata(transaction, conn)
      end

      :ok = Transaction.complete(transaction)

      conn
    end)
    |> assign(:appsignal_transaction, transaction)
  end


  def submit_http_error(pid, conn, reason, message, stack) do
    case Appsignal.TransactionRegistry.lookup(self) do
      nil -> nil
      transaction ->
        Transaction.set_error(transaction, "#{inspect reason}", message, Appsignal.ErrorHandler.format_stack(stack))
        if Transaction.finish(transaction) == :sample do
          Transaction.set_request_metadata(transaction, conn)
        end
        Transaction.complete(transaction)
        Logger.debug("Submitting #{inspect transaction}: #{message}")
    end
  end

  defmacro __using__(_) do
    IO.inspect "using Appsigna.plug"

    quote do
      plug Appsignal.Plug

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          e ->
            IO.inspect "e: #{inspect e}"
            raise e
        end
      end

    end
  end

end
