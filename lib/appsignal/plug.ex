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

          conn = super(conn, opts)

          @transaction.set_action(transaction, Appsignal.Plug.extract_action(conn))
          if @transaction.finish(transaction) == :sample do
            @transaction.set_request_metadata(transaction, conn)
          end

          :ok = @transaction.complete(transaction)
          conn
        end
      end
    end

    @phoenix_message "HTTP request error"

    @doc """
    Returns a tuple with the exception's reason, message, stacktrace and the
    conn when passing the exception, a conn, and a stacktrace.
    """
    def extract_error_metadata(%Plug.Conn.WrapperError{reason: reason = %{}, conn: conn}, _conn, stack) do
      {reason, message} = Appsignal.ErrorHandler.extract_reason_and_message(reason, @phoenix_message)
      {reason, message, stack, conn}
    end
    def extract_error_metadata(%{plug_status: s}, _conn, _stack) when s < 500 do
      # Do not submit regular HTTP errors which have a status code
      nil
    end
    def extract_error_metadata(reason, conn, stack) do
      {reason, message} = Appsignal.ErrorHandler.extract_reason_and_message(reason, @phoenix_message)
      {reason, message, stack, conn}
    end

    def extract_action(%Plug.Conn{private: %{phoenix_action: action, phoenix_controller: controller}}) do
      merge_action_and_controller(action, controller)
    end
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
