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

  require Logger

  alias Appsignal.{Transaction,TransactionRegistry}

  @doc false
  defmacro __using__(_) do

    quote do
      plug Appsignal.Phoenix.Plug

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
  def maybe_submit_http_error(_, _, _) do
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


end
