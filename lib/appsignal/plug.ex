if Appsignal.plug? do
  defmodule Appsignal.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """

    defmacro __using__(_) do
      quote do
        @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

        def call(conn, opts) do
          id = Logger.metadata()[:request_id] || @transaction.generate_id()
          transaction = @transaction.start(id, :http_request)

          try do
            super(conn, opts)
          catch
            kind, error ->
              Plug.ErrorHandler.__catch__(conn, kind, error, fn(conn, _exception) ->
                case Appsignal.Plug.extract_error_metadata(error) do
                  {reason, message} ->
                    transaction
                    |> @transaction.set_error(reason, message, System.stacktrace)
                    |> finish_with_conn(conn)
                  nil -> conn
                end
              end)
          else
            conn -> finish_with_conn(transaction, conn)
          end
        end

        defp finish_with_conn(transaction, conn) do
          @transaction.set_action(transaction, Appsignal.Plug.extract_action(conn))
          if @transaction.finish(transaction) == :sample do
            @transaction.set_request_metadata(transaction, conn)
          end

          :ok = @transaction.complete(transaction)
          conn
        end
      end
    end

    @doc """
    Returns a tuple with the exception's reason and message unless the error has
    a status code under 500.
    """
    def extract_error_metadata(%{plug_status: status}) when status < 500 do
      nil
    end
    def extract_error_metadata(%Plug.Conn.WrapperError{reason: reason = %{}}) do
      Appsignal.ErrorHandler.extract_reason_and_message(reason, "HTTP request error")
    end
    def extract_error_metadata(reason) do
      Appsignal.ErrorHandler.extract_reason_and_message(reason, "HTTP request error")
    end

    @doc false
    def extract_error_metadata(reason, conn, stack) do
      IO.warn "Appsignal.Plug.extract_error_metadata/3 is deprecated. Use Appsignal.Plug.extract_error_metadata/1 instead."
      {reason, message} = extract_error_metadata(reason)
      {reason, message, stack, conn}
    end

    def extract_action(%Plug.Conn{private: %{phoenix_action: action, phoenix_controller: controller}}) do
      merge_action_and_controller(action, controller)
    end
    def extract_action(%Plug.Conn{private: %{phoenix_endpoint: _}}), do: nil
    def extract_action(%Plug.Conn{method: method, request_path: path}) do
      "#{method} #{path}"
    end

    defp merge_action_and_controller(action, controller) when is_atom(controller) do
      merge_action_and_controller(
        action,
        controller |> Atom.to_string |> String.trim_leading("Elixir.")
      )
    end
    defp merge_action_and_controller(action, controller) do
      "#{controller}##{action}"
    end
  end
end
