if Appsignal.plug?() do
  defmodule Appsignal.Plug do
    @moduledoc """
    Plug handler for Phoenix requests
    """

    defmacro __using__(_) do
      quote do
        @transaction Application.get_env(
                       :appsignal,
                       :appsignal_transaction,
                       Appsignal.Transaction
                     )

        def call(conn, opts) do
          transaction = @transaction.start(@transaction.generate_id(), :http_request)

          conn = Plug.Conn.put_private(conn, :appsignal_transaction, transaction)

          try do
            super(conn, opts)
          catch
            kind, reason ->
              stacktrace = System.stacktrace()
              exception = Exception.normalize(kind, reason, stacktrace)

              case Appsignal.Plug.extract_error_metadata(exception) do
                {reason, message} ->
                  transaction
                  |> @transaction.set_error(reason, message, stacktrace)
                  |> finish_with_conn(conn)

                nil ->
                  conn
              end

              :erlang.raise(kind, reason, stacktrace)
          else
            conn -> finish_with_conn(transaction, conn)
          end
        end

        defp finish_with_conn(transaction, conn) do
          try_set_action(transaction, conn)

          if @transaction.finish(transaction) == :sample do
            @transaction.set_request_metadata(transaction, conn)
          end

          :ok = @transaction.complete(transaction)
          conn
        end

        defp try_set_action(transaction, conn) do
          case Appsignal.Plug.extract_action(conn) do
            nil -> nil
            action -> @transaction.set_action(transaction, action)
          end
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
      IO.warn(
        "Appsignal.Plug.extract_error_metadata/3 is deprecated. Use Appsignal.Plug.extract_error_metadata/1 instead."
      )

      {reason, message} = extract_error_metadata(reason)
      {reason, message, stack, conn}
    end

    def extract_action(%Plug.Conn{
          private: %{phoenix_action: action, phoenix_controller: controller}
        }) do
      merge_action_and_controller(action, controller)
    end

    def extract_action(%Plug.Conn{private: %{phoenix_endpoint: _}}), do: nil

    def extract_action(%Plug.Conn{method: method, request_path: path}) do
      "#{method} #{path}"
    end

    def extract_sample_data(
          %Plug.Conn{
            params: params,
            host: host,
            method: method,
            script_name: script_name,
            request_path: request_path,
            port: port,
            query_string: query_string
          } = conn
        ) do
      %{
        "params" => Appsignal.Utils.ParamsFilter.filter_values(params),
        "environment" =>
          %{
            "host" => host,
            "method" => method,
            "script_name" => script_name,
            "request_path" => request_path,
            "port" => port,
            "query_string" => query_string,
            "request_uri" => url(conn),
            "peer" => peer(conn)
          }
          |> Map.merge(extract_request_headers(conn))
      }
    end

    @header_keys ~w(
      accept accept-charset accept-encoding accept-language cache-control
      connection content-length user-agent from negotiate pragma referer range

      auth-type gateway-interface path-translated remote-host remote-ident
      remote-user remote-addr request-method server-name server-port
      server-protocol request-uri path-info client-ip range

      x-request-start x-queue-start x-queue-time x-heroku-queue-wait-time
      x-application-start x-forwarded-for x-real-ip
    )

    def extract_request_headers(%Plug.Conn{req_headers: req_headers}) do
      for {key, value} <- req_headers, key in @header_keys do
        {"req_headers.#{key}", value}
      end
      |> Enum.into(%{})
    end

    def extract_meta_data(%Plug.Conn{method: method, request_path: path} = conn) do
      request_id =
        conn
        |> Plug.Conn.get_resp_header("x-request-id")
        |> List.first()

      %{
        "method" => method,
        "path" => path,
        "request_id" => request_id
      }
    end

    defp merge_action_and_controller(action, controller) when is_atom(controller) do
      merge_action_and_controller(
        action,
        controller |> Atom.to_string() |> String.trim_leading("Elixir.")
      )
    end

    defp merge_action_and_controller(action, controller) do
      "#{controller}##{action}"
    end

    defp url(%Plug.Conn{scheme: scheme, host: host, port: port, request_path: request_path}) do
      "#{scheme}://#{host}:#{port}#{request_path}"
    end

    defp peer(%Plug.Conn{peer: {host, port}}) do
      "#{:inet_parse.ntoa(host)}:#{port}"
    end
  end
end
