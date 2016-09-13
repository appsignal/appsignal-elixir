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
            import Appsignal.Phoenix
            case {Appsignal.TransactionRegistry.lookup(self), extract_error_metadata(e, conn, System.stacktrace)} do
              {nil, _} -> :skip
              {transaction, {reason, message, stack, conn}} ->
                submit_http_error(reason, message, stack, transaction, conn)
            end
            reraise e, System.stacktrace
        end
      end
    end
  end


  @doc false
  def extract_error_metadata(%Plug.Conn.WrapperError{reason: reason = %{}, conn: conn} = r, _conn, stack) do
    extract_error_metadata(reason, conn, stack)
  end
  def extract_error_metadata(%{plug_status: s} = r, conn) when s < 500 do
    # Do not submit regular HTTP errors which have a status code
    nil
  end
  def extract_error_metadata(%Protocol.UndefinedError{value: {:error, {error = %{}, stack}}}, conn, _stack) do
    extract_error_metadata(error, conn, stack)
  end
  def extract_error_metadata(r = %{}, conn, stack) do
    # Submit error
    {r.__struct__, Exception.message(r), stack, Map.get(r, :conn, conn)}
  end

  @doc false
  def submit_http_error(reason, message, stack, transaction, conn) do
    Transaction.set_error(transaction, "#{inspect reason}", message, Appsignal.ErrorHandler.format_stack(stack))
    if Transaction.finish(transaction) == :sample do
      Transaction.set_request_metadata(transaction, conn)
    end
    Transaction.complete(transaction)

    # explicitly remove the transaction here so the regular error handler doesn't submit it again
    :ok = TransactionRegistry.remove_transaction(transaction)

    Logger.debug("Submitting Phoenix error #{inspect transaction}: #{message}")
  end


end
