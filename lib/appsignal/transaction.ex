defmodule Appsignal.Transaction do
  @moduledoc """
  Functions related to Appsignal transactions

  This module contains functions for starting and stopping an
  Appsignal transaction, recording events and collecting metrics
  within a transaction, et cetera.

  """

  defstruct [:resource, :id]

  alias Appsignal.{Nif, Transaction, TransactionRegistry}

  @typedoc """
  Datatype which is used as a handle to the current Appsignal transaction.
  """
  @type t :: %Transaction{}

  @typedoc """
  The transaction's namespace
  """
  @type namespace :: :http_request | :background_job

  @valid_namespaces [:http_request, :background_job]


  @doc """
  Start a transaction

  Call this when a transaction such as a http request or background job starts.

  Parameters:
  - `transaction_id` The unique identifier of this transaction
  - `namespace` The namespace of this transaction. Must be one of `:http_request`, `:background_job`.

  The function returns a `%Transaction{}` struct for use with the
  other transaction functions in this module.

  The returned transaction is also associated with the calling
  process, so that processes / callbacks which don't get the
  transaction passed in can still look it up through the
  `Appsignal.TransactionRegistry`.

  """
  @spec start(String.t, namespace) :: Transaction.t
  def start(transaction_id, namespace)
  when is_binary(transaction_id) and namespace in @valid_namespaces do
    {:ok, resource} = Nif.start_transaction(transaction_id, Atom.to_string(namespace))
    transaction = %Appsignal.Transaction{resource: resource, id: transaction_id}
    TransactionRegistry.register(transaction)
    transaction
  end

  @doc """
  Start an event

  Call this when an event within a transaction you want to measure starts, such as
  an SQL query or http request.

  - `transaction`: The pointer to the transaction this event occurred in.

  """
  @spec start_event(Transaction.t) :: Transaction.t
  def start_event(%Transaction{} = transaction) do
    :ok = Nif.start_event(transaction.resource)
    transaction
  end

  @doc """
  Finish an event

  Call this when an event ends.

  - `transaction`: The pointer to the transaction this event occurred in
  - `name`: Name of the category of the event (sql.query, net.http)
  - `title`: Title of the event ('User load', 'Http request to google.com')
  - `body`: Body of the event, should not contain unique information per specific event (`select * from users where id=?`)
  - `body_format` Format of the event's body which can be used for sanitization, 0 for general and 1 for sql currently.
  """
  @spec finish_event(Transaction.t, String.t, String.t, String.t, integer) :: Transaction.t
  def finish_event(%Transaction{} = transaction, name, title, body, body_format \\ 0) do
    :ok = Nif.finish_event(transaction.resource, name, title, body, body_format)
    transaction
  end

  @doc """
  Record a finished event

  Call this when an event which you cannot track the start for
  ends. This function can only be used for events that do not have
  children such as database queries. GC metrics and allocation counts
  will be tracked in the parent of this event.

  - `transaction`: The pointer to the transaction this event occurred in
  - `name`: Name of the category of the event (sql.query, net.http)
  - `title`: Title of the event ('User load', 'Http request to google.com')
  - `body`: Body of the event, should not contain unique information per specific event (`select * from users where id=?`)
  - `duration`: Duration of this event in nanoseconds
  - `body_format` Format of the event's body which can be used for sanitization, 0 for general and 1 for sql currently.
  """
  @spec record_event(Transaction.t, String.t, String.t, String.t, integer, integer) :: Transaction.t
  def record_event(%Transaction{} = transaction, name, title, body, duration, body_format \\ 0) do
    :ok = Nif.record_event(transaction.resource, name, title, body, duration, body_format)
    transaction
  end


  @max_name_size 120

  @doc """
  Set an error for a transaction

  Call this when an error occurs within a transaction.

  - `transaction`: The pointer to the transaction this event occurred in
  - `name`: Name of the error (RuntimeError)
  - `message`: Message of the error ('undefined method call for something')
  - `backtrace`: Backtrace of the error; will be JSON encoded
  """
  @spec set_error(Transaction.t, String.t, String.t, any) :: Transaction.t
  def set_error(%Transaction{} = transaction, name, message, backtrace) do
    name = name |> String.split_at(@max_name_size) |> elem(0)
    :ok = Nif.set_error(transaction.resource, name, message, Poison.encode!(backtrace))
    transaction
  end

  @doc """
  Set sample data for a transaction

  Use this to add sample data if finish_transaction returns true.

  - `transaction`: The pointer to the transaction this event occurred in
  - `key`: Key of this piece of metadata (params, session_data)
  - `payload`: Metadata (e.g. `%{user_id: 1}`); will be JSON encoded
  """
  @spec set_sample_data(Transaction.t, String.t, any) :: Transaction.t
  def set_sample_data(%Transaction{} = transaction, key, payload) do
    :ok = Nif.set_sample_data(transaction.resource, key, Poison.encode!(payload))
    transaction
  end

  @doc """
  Set action of a transaction

  Call this when the identifying action of a transaction is known.

  - `transaction`: The pointer to the transaction this event occurred in
  - `action`: This transactions action (`"HomepageController.show"`)
  """
  @spec set_action(Transaction.t, String.t) :: Transaction.t
  def set_action(%Transaction{} = transaction, action) do
    :ok = Nif.set_action(transaction.resource, action)
    transaction
  end

  @doc """
  Set queue start time of a transaction

  Call this when the queue start time in miliseconds is known.

  - `transaction`: The pointer to the transaction this event occurred in
  - `queue_start`: Transaction queue start time in ms if known, otherwise -1
  """
  @spec set_queue_start(Transaction.t, integer) :: Transaction.t
  def set_queue_start(%Transaction{} = transaction, start \\ -1) do
    :ok = Nif.set_queue_start(transaction.resource, start)
    transaction
  end

  @doc """
  Set metadata for a transaction

  Call this when an error occurs within a transaction to set more detailed data about the error

  - `transaction`: The pointer to the transaction this event occurred in
  - `key`: Key of this piece of metadata (`"email"`)
  - `value`: Value of this piece of metadata (`"thijs@appsignal.com"`)
  """
  @spec set_meta_data(Transaction.t, String.t, String.t) :: Transaction.t
  def set_meta_data(%Transaction{} = transaction, key, value) do
    :ok = Nif.set_meta_data(transaction.resource, key, value)
    transaction
  end

  @doc """
  Finish a transaction

  Call this when a transaction such as a http request or background job ends.

  - `transaction`: The pointer to the transaction this event occurred in

  Returns `:sample` wether sample data for this transaction should be
  collected.
  """
  @spec finish(Transaction.t) :: :sample | :no_sample
  def finish(%Transaction{} = transaction) do
    Nif.finish(transaction.resource)
  end

  @doc """
  Complete a transaction

  Call this after finishing a transaction (and adding sample data if necessary).

  - `transaction`: The pointer to the transaction this event occurred in
  """
  @spec complete(Transaction.t) :: :ok
  def complete(%Transaction{} = transaction) do
    :ok = Nif.complete(transaction.resource)
  end

  @doc """
  Generate a random id as a string to use as transaction identifier.
  """
  @spec generate_id :: String.t
  def generate_id do
    :crypto.strong_rand_bytes(8) |> Base.hex_encode32(case: :lower, padding: false)
  end

  defimpl Inspect do
    def inspect(transaction, _opts) do
      "AppSignal.Transaction{#{transaction.id}}"
    end
  end


  alias Plug.Conn

  @doc """
  Set the request metadata, given a Plug.Conn.t.
  """
  @spec set_request_metadata(Transaction.t, Plug.Conn.t) :: Transaction.t
  def set_request_metadata(%Transaction{} = transaction, %Conn{} = conn) do

    # preprocess conn
    conn = conn
    |> Conn.fetch_query_params

    # collect sample data
    transaction
    |> Transaction.set_sample_data("params", conn.params |> filter_values(filter_parameters))
    |> Transaction.set_sample_data("environment", request_environment(conn))
    transaction
  end


  @conn_fields ~w(host method script_name request_path port schema query_string)a
  defp request_environment(conn) do
    @conn_fields
    |> Enum.map(fn(k) -> {k, Map.get(conn, k)} end)
    |> Enum.into(%{})
    |> Map.put(:request_uri, url(conn))
    |> Map.put(:peer, peer(conn))
  end

  defp url(%Plug.Conn{scheme: scheme, host: host, port: port} = conn) do
    "#{scheme}://#{host}:#{port}#{conn.request_path}"
  end

  defp peer(%Plug.Conn{peer: {host, port}}) do
    "#{:inet_parse.ntoa host}:#{port}"
  end

  def filter_parameters do
    Application.get_env(:appsignal, :config)[:filter_parameters]
    || Application.get_env(:phoenix, :config)[:filter_parameters]
    || []
  end

  def filter_values(%{__struct__: mod} = struct, _filter_params) when is_atom(mod) do
    struct
  end
  def filter_values(%{} = map, filter_params) do
    Enum.into map, %{}, fn{k, v} ->
      if is_binary(k) and String.contains?(k, filter_params) do
        {k, "[FILTERED]"}
      else
        {k, filter_values(v, filter_params)}
      end
    end
  end
  def filter_values([_|_] = list, filter_params) do
    Enum.map(list, &filter_values(&1, filter_params))
  end
  def filter_values(other, _filter_params), do: other

  @doc """
  Given the transaction and a %PlugConn{}, try to set the Phoenix controller module / action in the transaction.
  """
  def try_set_action(transaction, conn) do
    try do
      action_str = "#{Phoenix.Controller.controller_module(conn)}##{Phoenix.Controller.action_name(conn)}"
      <<"Elixir.", action :: binary>> = action_str
      Transaction.set_action(transaction, action)
    catch
      _, _ -> :ok
    end
  end
end
