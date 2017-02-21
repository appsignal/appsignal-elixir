if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """

    defmacro __using__(_) do
      quote do
        @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

        def call(conn, opts) do
          id = Logger.metadata()[:request_id] || @transaction.generate_id()
          transaction = @transaction.start(id, :http_request)

          conn = super(conn, opts)

          @transaction.try_set_action(transaction, conn)
          if @transaction.finish(transaction) == :sample do
            @transaction.set_request_metadata(transaction, conn)
          end

          :ok = @transaction.complete(transaction)
          conn
        end
      end
    end
  end
end
