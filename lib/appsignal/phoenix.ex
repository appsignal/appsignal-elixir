if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix do
    @moduledoc """
    Instrumentation of Phoenix requests

    To integrate AppSignal with Phoenix, *use* the `Appsignal.Phoenix` module in
    your `endpoint.ex` file, just before your router:

    ```
    use Appsignal.Phoenix
    ```

    This will install a plug which measures request time, and also will
    trap common HTTP errors (like 4xx status codes).

    """

    require Logger

    @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)
    alias Appsignal.TransactionRegistry

    @doc false
    defmacro __using__(_) do
      quote do
        use Appsignal.Plug
      end
    end

    @doc false
    def extract_error_metadata(reason, conn, stack) do
      IO.warn "Appsignal.Phoenix.extract_error_metadata/3 is deprecated. Use Appsignal.Plug.extract_error_metadata/1 instead."
      Appsignal.Plug.extract_error_metadata(reason, conn, stack)
    end

    @doc false
    def submit_http_error(reason, message, stack, transaction, conn) do
      IO.warn "Appsignal.Phoenix.submit_http_error/5 is deprecated."

      @transaction.set_error(transaction, reason, message, stack)
      if @transaction.finish(transaction) == :sample do
        @transaction.set_request_metadata(transaction, conn)
      end
      @transaction.complete(transaction)

      # explicitly remove the transaction here so the regular error handler doesn't submit it again
      :ok = TransactionRegistry.remove_transaction(transaction)

      Logger.debug("Submitting Phoenix error #{inspect transaction}: #{message}")
    end
  end
end
