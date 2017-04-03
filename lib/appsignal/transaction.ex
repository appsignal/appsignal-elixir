defmodule Appsignal.TransactionBehaviour do
  @callback start(String.t, String.t) :: Appsignal.Transaction.t
  @callback start_event() :: Appsignal.Transaction.t
  @callback finish_event(Appsignal.Transaction.t | nil, String.t, String.t, any, integer) :: Appsignal.Transaction.t
  @callback finish() :: :sample | :no_sample
  @callback finish(Transaction.t | nil) :: :sample | :no_sample
  @callback complete() :: :ok
  @callback complete(Transaction.t | nil) :: :ok
  @callback set_error(Transaction.t | nil, String.t, String.t, any) :: Transaction.t

  if Appsignal.phoenix? do
    @callback try_set_action(Plug.Conn.t) :: :ok
    @callback try_set_action(Appsignal.Transaction.t, Plug.Conn.t) :: :ok
  end

  if Appsignal.plug? do
    @callback set_request_metadata(Transaction.t | nil, Plug.Conn.t) :: Transaction.t
  end
end

defmodule Appsignal.Transaction do
  @behaviour Appsignal.TransactionBehaviour
  use Appsignal.Config

  @moduledoc """
  Functions related to AppSignal transactions

  This module contains functions for starting and stopping an
  AppSignal transaction, recording events and collecting metrics
  within a transaction, et cetera.

  All functions take a `Transaction` as their first parameter. It is
  possible to omit this parameter, in which case it is assumed that
  the calling process has already an associated Transaction (the
  "current" transaction). This is the case after `Transaction.start/2`
  has been called from within the same process.


  """

  defstruct [:resource, :id]

  alias Appsignal.{Nif, Transaction, TransactionRegistry, Backtrace}

  @typedoc """
  Datatype which is used as a handle to the current AppSignal transaction.
  """
  @type t :: %Transaction{}

  @doc """
  Start a transaction

  Call this when a transaction such as a http request or background job starts.

  Parameters:
  - `transaction_id` The unique identifier of this transaction.
  - `namespace` The namespace of this transaction. Defaults to :background_job.

  The function returns a `%Transaction{}` struct for use with the
  other transaction functions in this module.

  The returned transaction is also associated with the calling
  process, so that processes / callbacks which don't get the
  transaction passed in can still look it up through the
  `Appsignal.TransactionRegistry`.

  """
  @spec start(String.t, String.t) :: Transaction.t
  def start(transaction_id, namespace) when is_binary(transaction_id) do
    {:ok, resource} = Nif.start_transaction(transaction_id, Atom.to_string(namespace))
    transaction = %Appsignal.Transaction{resource: resource, id: transaction_id}
    TransactionRegistry.register(transaction)
    transaction
  end

  @doc """
  Start an event for the current transaction. See `start_event/1`
  """
  @spec start_event() :: Transaction.t
  def start_event() do
    start_event(lookup())
  end

  @doc """
  Start an event

  Call this when an event within a transaction you want to measure starts, such as
  an SQL query or http request.

  - `transaction`: The pointer to the transaction this event occurred in.

  """
  @spec start_event(Transaction.t | nil) :: Transaction.t
  def start_event(nil), do: nil
  def start_event(%Transaction{} = transaction) do
    :ok = Nif.start_event(transaction.resource)
    transaction
  end

  @doc """
  Finish an event for the current transaction. See `finish_event/5`.
  """
  @spec finish_event(String.t, String.t, String.t, integer) :: Transaction.t
  def finish_event(name, title, body, body_format \\ 0) do
    finish_event(lookup(), name, title, body, body_format)
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
  @spec finish_event(Transaction.t | nil, String.t, String.t, any, integer) :: Transaction.t
  def finish_event(nil, _name, _title, _body, _body_format), do: nil
  def finish_event(%Transaction{} = transaction, name, title, body, body_format) when is_binary(body) do
    :ok = Nif.finish_event(transaction.resource, name, title, body, body_format)
    transaction
  end

  def finish_event(%Transaction{} = transaction, name, title, body, body_format) do
    encoded_body = Appsignal.Utils.DataEncoder.encode(body)
    :ok = Nif.finish_event_data(transaction.resource, name, title, encoded_body, body_format)
    transaction
  end


  @doc """
  Record a finished event for the current transaction. See `record_event/6`.
  """
  @spec record_event(String.t, String.t, String.t, integer, integer) :: Transaction.t
  def record_event(name, title, body, duration, body_format \\ 0) do
    record_event(lookup(), name, title, body, duration, body_format)
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
  @spec record_event(Transaction.t | nil, String.t, String.t, String.t, integer, integer) :: Transaction.t
  def record_event(nil, _name, _title, _body, _duration, _body_format), do: nil
  def record_event(%Transaction{} = transaction, name, title, body, duration, body_format) do
    :ok = Nif.record_event(transaction.resource, name, title, body, body_format, duration)
    transaction
  end


  @doc """
  Set an error for a the current transaction. See `set_error/4`.
  """
  @spec set_error(String.t, String.t, any) :: Transaction.t
  def set_error(name, message, backtrace) do
    set_error(lookup(), name, message, backtrace)
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
  @spec set_error(Transaction.t | nil, String.t, String.t, any) :: Transaction.t
  def set_error(nil, _name, _message, _backtrace), do: nil
  def set_error(%Transaction{} = transaction, name, message, backtrace) do
    name = name |> String.split_at(@max_name_size) |> elem(0)
    backtrace_data = backtrace
    |> Backtrace.from_stacktrace
    |> Appsignal.Utils.DataEncoder.encode

    :ok = Nif.set_error(transaction.resource, name, message, backtrace_data)
    transaction
  end

  @doc """
  Set sample data for the current transaction. See `set_sample_data/3`.
  """
  @spec set_sample_data(String.t, any) :: Transaction.t
  def set_sample_data(key, payload) do
    set_sample_data(lookup(), key, payload)
  end

  @doc """
  Set sample data for a transaction

  Use this to add sample data if finish_transaction returns true.

  - `transaction`: The pointer to the transaction this event occurred in
  - `key`: Key of this piece of metadata (params, session_data)
  - `payload`: Metadata (e.g. `%{user_id: 1}`); will be JSON encoded
  """
  @spec set_sample_data(Transaction.t | nil, String.t, any) :: Transaction.t
  def set_sample_data(nil, _key, _payload), do: nil
  def set_sample_data(%Transaction{} = transaction, key, payload) do
    payload_data = Appsignal.Utils.DataEncoder.encode(payload)
    :ok = Nif.set_sample_data(transaction.resource, key, payload_data)
    transaction
  end

  @doc """
  Set action of the current transaction. See `set_action/1`.
  """
  @spec set_action(String.t) :: Transaction.t
  def set_action(action) do
    set_action(lookup(), action)
  end

  @doc """
  Set action of a transaction

  Call this when the identifying action of a transaction is known.

  - `transaction`: The pointer to the transaction this event occurred in
  - `action`: This transactions action (`"HomepageController.show"`)
  """
  @spec set_action(Transaction.t | nil, String.t) :: Transaction.t
  def set_action(nil, _action), do: nil
  def set_action(%Transaction{} = transaction, action) do
    :ok = Nif.set_action(transaction.resource, action)
    transaction
  end

  @doc """
  Set queue start time of the current transaction. See `set_queue_start/2`.
  """
  @spec set_queue_start(integer) :: Transaction.t
  def set_queue_start(start \\ -1) do
    set_queue_start(lookup(), start)
  end

  @doc """
  Set queue start time of a transaction

  Call this when the queue start time in miliseconds is known.

  - `transaction`: The pointer to the transaction this event occurred in
  - `queue_start`: Transaction queue start time in ms if known
  """
  @spec set_queue_start(Transaction.t | nil, integer) :: Transaction.t
  def set_queue_start(nil, _start), do: nil
  def set_queue_start(%Transaction{} = transaction, start) do
    :ok = Nif.set_queue_start(transaction.resource, start)
    transaction
  end

  @doc """
  Set metadata for the current transaction from an enumerable.
  The enumerable needs to be a keyword list or a map.
  """
  @spec set_meta_data(Enum.t) :: Transaction.t
  def set_meta_data(values) do
    transaction = lookup()
    values |> Enum.each(fn({key, value}) ->
      Transaction.set_meta_data(transaction, key, value)
    end)
    transaction
  end

  @doc """
  Set metadata for the current transaction. See `set_meta_data/3`.
  """
  @spec set_meta_data(String.t, String.t) :: Transaction.t
  def set_meta_data(key, value) do
    set_meta_data(lookup(), key, value)
  end

  @doc """
  Set metadata for a transaction

  Call this when an error occurs within a transaction to set more detailed data about the error

  - `transaction`: The pointer to the transaction this event occurred in
  - `key`: Key of this piece of metadata (`"email"`)
  - `value`: Value of this piece of metadata (`"thijs@appsignal.com"`)
  """
  @spec set_meta_data(Transaction.t | nil, String.t, String.t) :: Transaction.t
  def set_meta_data(nil, _key, _value), do: nil
  def set_meta_data(%Transaction{} = transaction, key, value) when is_binary(key) and is_binary(value) do
    :ok = Nif.set_meta_data(transaction.resource, key, value)
    transaction
  end
  def set_meta_data(%Transaction{} = transaction, key, value) do
    set_meta_data(transaction, to_s(key), to_s(value))
  end

  @doc """
  Finish the current transaction. See `finish/1`.
  """
  @spec finish() :: :sample | :no_sample
  def finish() do
    finish(lookup())
  end

  @doc """
  Finish a transaction

  Call this when a transaction such as a http request or background job ends.

  - `transaction`: The pointer to the transaction this event occurred in

  Returns `:sample` whether sample data for this transaction should be
  collected.
  """
  @spec finish(Transaction.t | nil) :: :sample | :no_sample
  def finish(nil), do: nil
  def finish(%Transaction{} = transaction) do
    Nif.finish(transaction.resource)
  end

  @doc """
  Complete the current transaction. See `complete/1`.
  """
  @spec complete() :: :ok
  def complete() do
    complete(lookup())
  end

  @doc """
  Complete a transaction

  Call this after finishing a transaction (and adding sample data if necessary).

  - `transaction`: The pointer to the transaction this event occurred in
  """
  @spec complete(Transaction.t | nil) :: :ok
  def complete(nil), do: nil
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


  # Lookup the current AppSignal transaction in the transaction registry.
  defp lookup() do
    TransactionRegistry.lookup(self())
  end

  defimpl Inspect do
    def inspect(transaction, _opts) do
      "AppSignal.Transaction{#{transaction.id}}"
    end
  end

  if Appsignal.plug? do
    @doc """
    Set the request metadata, given a Plug.Conn.t.
    """
    @spec set_request_metadata(Transaction.t | nil, Plug.Conn.t) :: Transaction.t
    def set_request_metadata(%Transaction{} = transaction, %Plug.Conn{} = conn) do

      # preprocess conn
      conn = conn
      |> Plug.Conn.fetch_query_params

      # collect sample data
      transaction
      |> Transaction.set_sample_data("params", conn.params |> Appsignal.Utils.ParamsFilter.filter_values)
      |> Transaction.set_sample_data("environment", request_environment(conn))

      # Add session data
      if !config()[:skip_session_data] and conn.private[:plug_session_fetch] == :done do
        Transaction.set_sample_data(
          transaction, "session_data", conn.private[:plug_session]
        )
      else
        transaction
      end
    end

    @conn_fields ~w(host method script_name request_path port query_string)a
    defp request_environment(conn) do
      env =
        @conn_fields
        |> Enum.map(fn(k) -> {k, Map.get(conn, k)} end)
        |> Enum.into(%{})
        |> Map.put(:request_uri, url(conn))
        |> Map.put(:peer, peer(conn))
      # add all request headers
      Enum.reduce(conn.req_headers || [], env,
        fn({header, value}, env) ->
          Map.put(env, "req_header.#{header}", value)
        end)
    end

    defp url(%Plug.Conn{scheme: scheme, host: host, port: port} = conn) do
      "#{scheme}://#{host}:#{port}#{conn.request_path}"
    end

    defp peer(%Plug.Conn{peer: {host, port}}) do
      "#{:inet_parse.ntoa host}:#{port}"
    end
  end

  if Appsignal.phoenix? do
    @doc """
    Given the transaction and a %Plug.Conn{}, try to set the Phoenix controller module / action in the transaction.
    """
    def try_set_action(conn), do: try_set_action(lookup(), conn)
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

  defp to_s(value) when is_atom(value), do: Atom.to_string(value)
  defp to_s(value) when is_integer(value), do: Integer.to_string(value)
  defp to_s(value) when is_binary(value), do: value


  @doc """
  Return the transaction for the given process

  Creates a new one when not found. Can also return `nil`; in that
  case, we should not continue submitting the transaction.
  """
  def lookup_or_create_transaction(origin \\ nil, namespace \\ :background_job) do
    origin = origin || self()
    case TransactionRegistry.lookup(origin, true) do
      :removed ->
        # transaction existed but has already been submitted, on the timer to be removed
        nil
      nil ->
        # could not find a linked transaction; start new transaction
        start("_" <> generate_id(), namespace)
      t ->
        t
    end
  end
end
