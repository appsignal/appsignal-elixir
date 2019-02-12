if Appsignal.phoenix?() do
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
    alias Appsignal.{Error, TransactionRegistry}

    @doc false
    defmacro __using__(_) do
      quote do
        use Appsignal.Plug
      end
    end

    @doc false
    @deprecated "Use Appsignal.Error.metadata/1 instead"
    def extract_error_metadata(error, conn, stack) do
      {exception, stacktrace} = Error.normalize(error, stack)
      {name, message} = Error.metadata(exception)
      {name, message, stacktrace, conn}
    end

    @doc false
    def submit_http_error(reason, message, stack, transaction, conn) do
      IO.warn("Appsignal.Phoenix.submit_http_error/5 is deprecated.")

      @transaction.set_error(transaction, reason, message, stack)

      if @transaction.finish(transaction) == :sample do
        @transaction.set_request_metadata(transaction, conn)
      end

      @transaction.complete(transaction)

      # explicitly remove the transaction here so the regular error handler doesn't submit it again
      :ok = TransactionRegistry.remove_transaction(transaction)

      Logger.debug(fn ->
        "Submitting Phoenix error #{inspect(transaction)}: #{message}"
      end)
    end
  end
end
