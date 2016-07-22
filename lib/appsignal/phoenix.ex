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

  alias Appsignal.{Transaction,TransactionRegistry}
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


  @doc false
  def maybe_submit_http_error(_e, nil) do
    # transaction not found in registry
    nil
  end
  def maybe_submit_http_error(%Plug.Conn.WrapperError{conn: conn, reason: reason}, transaction, _conn) do
    maybe_submit_http_error(reason, transaction, conn)
  end
  def maybe_submit_http_error(%{plug_status: s} = r, transaction, conn) when s > 0 do
    submit_http_error(r.__struct__, r.message, transaction, Map.get(r, :conn, conn))
  end
  def maybe_submit_http_error(_, _) do
    # Unknown error
    nil
  end

  def submit_http_error(reason, message, transaction, conn) do
    stack = System.stacktrace
    Transaction.set_error(transaction, "#{inspect reason}", message, Appsignal.ErrorHandler.format_stack(stack))
    if Transaction.finish(transaction) == :sample do
      Transaction.set_request_metadata(transaction, conn)
    end
    Transaction.complete(transaction)

    # explicitly remove the transaction here so the regular error handler doesn't submit it again
    :ok = TransactionRegistry.remove_transaction(transaction)

    Logger.debug("Submitting #{inspect transaction}: #{message}")
  end

  @doc false
  defmacro __using__(_) do

    quote do
      plug Appsignal.Phoenix

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          e ->
            Appsignal.Phoenix.maybe_submit_http_error(e, Appsignal.TransactionRegistry.lookup(self), conn)
            raise e
        end
      end

    end
  end

end
