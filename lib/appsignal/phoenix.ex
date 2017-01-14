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
  alias Appsignal.ErrorHandler

  @doc false
  defmacro __using__(_) do
    quote do
      plug Appsignal.Phoenix.Plug

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          e ->
            stacktrace = System.stacktrace
            import Appsignal.Phoenix
            case {Appsignal.TransactionRegistry.lookup(self()), extract_error_metadata(e, conn, stacktrace)} do
              {nil, _} -> :skip
              {_, nil} -> :skip
              {transaction, {reason, message, stack, conn}} ->
                submit_http_error(reason, message, stack, transaction, conn)
            end
            reraise e, stacktrace
        end
      end
    end
  end

  @phoenix_message "HTTP request error"

  @doc false
  def extract_error_metadata(%Plug.Conn.WrapperError{reason: reason = %{}, conn: conn}, _conn, stack) do
    {reason, message} = ErrorHandler.extract_reason_and_message(reason, @phoenix_message)
    {reason, message, stack, conn}
  end
  def extract_error_metadata(%{plug_status: s}, _conn, _stack) when s < 500 do
    # Do not submit regular HTTP errors which have a status code
    nil
  end
  def extract_error_metadata(reason, conn, stack) do
    {reason, message} = ErrorHandler.extract_reason_and_message(reason, @phoenix_message)
    {reason, message, stack, conn}
  end
  def extract_error_metadata(r, conn, stack) when is_binary(r) do
    extract_error_metadata(RuntimeError.exception(r), conn, stack)
  end
  def extract_error_metadata(r, conn, stack) when is_atom(r) do
    extract_error_metadata(r.exception([]), conn, stack)
  end


  @doc false
  def submit_http_error(reason, message, stack, transaction, conn) do
    Transaction.set_error(transaction, reason, message, stack)
    Transaction.try_set_action(transaction, conn)
    if Transaction.finish(transaction) == :sample do
      Transaction.set_request_metadata(transaction, conn)
    end
    Transaction.complete(transaction)

    # explicitly remove the transaction here so the regular error handler doesn't submit it again
    :ok = TransactionRegistry.remove_transaction(transaction)

    Logger.debug("Submitting Phoenix error #{inspect transaction}: #{message}")
  end

end
