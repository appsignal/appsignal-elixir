if Appsignal.plug?() do
  defmodule Appsignal.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """
    import Appsignal.Utils

    defmacro __using__(_) do
      quote do
        @transaction Application.get_env(
                       :appsignal,
                       :appsignal_transaction,
                       Appsignal.Transaction
                     )

        def call(conn, opts) do
          if Appsignal.Config.active?() do
            transaction =
              @transaction.generate_id()
              |> @transaction.start(:http_request)
              |> Appsignal.Plug.try_set_action(conn)

            conn = Plug.Conn.put_private(conn, :appsignal_transaction, transaction)

            try do
              super(conn, opts)
            catch
              kind, reason -> Appsignal.Plug.handle_error(conn, kind, reason, System.stacktrace())
            else
              conn -> Appsignal.Plug.finish_with_conn(transaction, conn)
            end
          else
            super(conn, opts)
          end
        end

        defoverridable call: 2
      end
    end

    @transaction Application.get_env(
                   :appsignal,
                   :appsignal_transaction,
                   Appsignal.Transaction
                 )

    def handle_error(_conn, kind, %{plug_status: status} = reason, stack) when status < 500 do
      :erlang.raise(kind, reason, stack)
    end

    def handle_error(_conn, :error, %Plug.Conn.WrapperError{} = original_reason, _stack) do
      %{conn: conn, kind: kind, reason: reason, stack: stack} = original_reason
      do_handle_error(reason, stack, conn)

      :erlang.raise(kind, original_reason, stack)
    end

    def handle_error(conn, kind, reason, stack) do
      do_handle_error(reason, stack, conn)

      :erlang.raise(kind, reason, stack)
    end

    defp do_handle_error(
           error,
           stack,
           %Plug.Conn{private: %{appsignal_transaction: transaction}} = conn
         ) do
      Appsignal.ErrorHandler.handle_error(transaction, error, stack, conn)
      Appsignal.TransactionRegistry.ignore(self())
    end

    defp do_handle_error(_exception, _stack, _conn), do: :ok

    def finish_with_conn(transaction, conn) do
      if @transaction.finish(transaction) == :sample do
        @transaction.set_request_metadata(transaction, conn)
      end

      @transaction.complete(transaction)
      conn
    end

    def try_set_action(transaction, conn) do
      action = Appsignal.Plug.extract_action(conn)
      @transaction.set_action(transaction, action)
    end

    @doc false
    @deprecated "Use Appsignal.Error.metadata/1 instead."
    def extract_error_metadata(error) do
      {exception, _stacktrace} = Appsignal.Error.normalize(error, [])
      Appsignal.Error.metadata(exception)
    end

    @doc false
    @deprecated "Use Appsignal.Error.metadata/1 instead."
    def extract_error_metadata(error, conn, stack) do
      {exception, stacktrace} = Appsignal.Error.normalize(error, stack)
      {name, message} = Appsignal.Error.metadata(exception)
      {name, message, stacktrace, conn}
    end

    def extract_action(%Plug.Conn{
          private: %{phoenix_action: action, phoenix_controller: controller}
        }) do
      "#{module_name(controller)}##{action}"
    end

    def extract_action(%Plug.Conn{private: %{phoenix_endpoint: _}}), do: nil

    def extract_action(%Plug.Conn{method: _method, request_path: _path}) do
      "unknown"
    end

    def extract_sample_data(
          %Plug.Conn{
            params: params,
            host: host,
            method: method,
            request_path: request_path,
            port: port
          } = conn
        ) do
      %{
        "params" => Appsignal.Utils.MapFilter.filter_parameters(params),
        "environment" =>
          %{
            "host" => host,
            "method" => method,
            "request_path" => request_path,
            "port" => port,
            "request_uri" => url(conn)
          }
          |> Map.merge(extract_request_headers(conn))
      }
    end

    def extract_request_headers(%Plug.Conn{req_headers: req_headers}) do
      for {key, value} <- req_headers,
          key in Appsignal.Config.request_headers() do
        {"req_headers.#{key}", value}
      end
      |> Enum.into(%{})
    end

    def extract_meta_data(%Plug.Conn{method: method, request_path: path, status: status} = conn) do
      request_id =
        conn
        |> Plug.Conn.get_resp_header("x-request-id")
        |> List.first()

      %{
        "method" => method,
        "path" => path,
        "request_id" => request_id,
        "http_status_code" => status
      }
    end

    defp url(%Plug.Conn{scheme: scheme, host: host, port: port, request_path: request_path}) do
      "#{scheme}://#{host}:#{port}#{request_path}"
    end
  end
end
