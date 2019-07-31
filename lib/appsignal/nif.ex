defmodule Appsignal.NifBehaviour do
  @callback loaded?() :: boolean()
  @callback running_in_container?() :: boolean()
end

defmodule Appsignal.Nif do
  @behaviour Appsignal.NifBehaviour
  @moduledoc """

  It's a NIF! Oh no!

  While people generally think NIFs are a bad idea, the overhead of
  this particular NIF is low. The C code that the NIF calls has been
  designed to be as fast as possible and to do as little as possible
  on the calling thread.

  Internally, the AppSignal NIF works as follows: it fork/execs a
  separate agent process, to which the NIF sends its data (protobuf)
  over a unix socket. This agent process (which is a separate unix
  process!) then takes care of sending the data the server
  periodically.

  The C library that the NIF interfaces with, is specifically written
  with performance in mind and is very robust and battle tested;
  written in Rust and it is the same code that the Ruby AppSignal Gem
  uses, which is used in production in thousands of sites.

  While doing native Elixir protobufs to communicate directly with
  this agent makes more sense from a BEAM standpoint, from a
  maintainability point the NIF choice is more logical because
  AppSignal is planning more language integrations in the future (PHP,
  Java) which all will use this same C library and agent process.

  """

  @on_load :init

  def init do
    path = :filename.join(:code.priv_dir(:appsignal), 'appsignal_extension')

    case :erlang.load_nif(path, 1) do
      :ok ->
        :ok

      {:error, {:load_failed, reason}} ->
        arch = :erlang.system_info(:system_architecture)

        IO.warn(
          "Error loading NIF (Is your operating system (#{arch}) supported? Please check http://docs.appsignal.com/support/operating-systems.html):\n#{
            reason
          }"
        )

        :ok
    end
  end

  def agent_version do
    case :appsignal
         |> :code.priv_dir()
         |> Path.join("appsignal.version")
         |> File.read() do
      {:ok, contents} -> String.trim(contents)
      _ -> nil
    end
  end

  def env_put(key, value) do
    _env_put(key, value)
  end

  def env_get(key) do
    _env_get(key)
  end

  def env_delete(key) do
    _env_delete(key)
  end

  def env_clear do
    _env_clear()
  end

  def start do
    _start()
  end

  def stop do
    _stop()
  end

  def diagnose do
    _diagnose()
  end

  def start_transaction(transaction_id, namespace) do
    _start_transaction(transaction_id, namespace)
  end

  def start_event(transaction_resource) do
    _start_event(transaction_resource)
  end

  def finish_event(transaction_resource, name, title, body, body_format) do
    _finish_event(transaction_resource, name, title, body, body_format)
  end

  def finish_event_data(transaction_resource, name, title, body, body_format) do
    _finish_event_data(transaction_resource, name, title, body, body_format)
  end

  def record_event(transaction_resource, name, title, body, body_format, duration) do
    _record_event(transaction_resource, name, title, body, body_format, duration)
  end

  def set_error(transaction_resource, error, message, backtrace) do
    _set_error(transaction_resource, error, message, backtrace)
  end

  def set_sample_data(transaction_resource, key, payload) do
    _set_sample_data(transaction_resource, key, payload)
  end

  def set_action(transaction_resource, action) do
    _set_action(transaction_resource, action)
  end

  def set_namespace(transaction_resource, namespace) do
    _set_namespace(transaction_resource, namespace)
  end

  def set_queue_start(transaction_resource, start) do
    _set_queue_start(transaction_resource, start)
  end

  def set_meta_data(transaction_resource, key, value) do
    _set_meta_data(transaction_resource, key, value)
  end

  def finish(transaction_resource) do
    _finish(transaction_resource)
  end

  def complete(transaction_resource) do
    _complete(transaction_resource)
  end

  def set_gauge(key, value, tags) do
    _set_gauge(key, value, tags)
  end

  def increment_counter(key, count, tags) do
    _increment_counter(key, count, tags)
  end

  def add_distribution_value(key, value, tags) do
    _add_distribution_value(key, value, tags)
  end

  def data_map_new do
    _data_map_new()
  end

  def data_set_string(resource, key, value) do
    _data_set_string(resource, key, value)
  end

  def data_set_string(resource, value) do
    _data_set_string(resource, value)
  end

  def data_set_integer(resource, key, value) do
    _data_set_integer(resource, key, value)
  end

  def data_set_integer(resource, value) do
    _data_set_integer(resource, value)
  end

  def data_set_float(resource, key, value) do
    _data_set_float(resource, key, value)
  end

  def data_set_float(resource, value) do
    _data_set_float(resource, value)
  end

  def data_set_boolean(resource, key, value) do
    _data_set_boolean(resource, key, value)
  end

  def data_set_boolean(resource, value) do
    _data_set_boolean(resource, value)
  end

  def data_set_nil(resource, key) do
    _data_set_nil(resource, key)
  end

  def data_set_nil(resource) do
    _data_set_nil(resource)
  end

  def data_set_data(resource, key, value) do
    _data_set_data(resource, key, value)
  end

  def data_set_data(resource, value) do
    _data_set_data(resource, value)
  end

  def data_list_new do
    _data_list_new()
  end

  def running_in_container? do
    _running_in_container()
  end

  def loaded? do
    _loaded()
  end

  def trace_id(reference) do
    _trace_id(reference)
  end

  def span_id(reference) do
    _span_id(reference)
  end

  def create_root_span(name) do
    _create_root_span(name)
  end

  def create_child_span(trace_id, span_id, name) do
    _create_child_span(trace_id, span_id, name)
  end

  def set_span_attribute_string(reference, key, value) do
    _set_span_attribute_string(reference, key, value)
  end

  def close_span(reference) do
    _close_span(reference)
  end

  if Mix.env() in [:test, :test_phoenix] do
    def data_to_json(reference) do
      _data_to_json(reference)
    end

    def transaction_to_json(resource) do
      _transaction_to_json(resource)
    end
  end

  def _env_put(_key, _value) do
    :ok
  end

  def _env_get(_key) do
    ''
  end

  def _env_delete(_key) do
    :ok
  end

  def _env_clear do
    :ok
  end

  def _start do
    :ok
  end

  def _stop do
    :ok
  end

  def _diagnose do
    :error
  end

  def _start_transaction(_id, _namespace) do
    if System.otp_release() >= "20" do
      {:ok, make_ref()}
    else
      {:ok, <<>>}
    end
  end

  def _start_event(_transaction_resource) do
    :ok
  end

  def _finish_event(_transaction_resource, _name, _title, _body, _body_format) do
    :ok
  end

  def _finish_event_data(_transaction_resource, _name, _title, _body, _body_format) do
    :ok
  end

  def _record_event(_transaction_resource, _name, _title, _body, _body_format, _duration) do
    :ok
  end

  def _set_error(_transaction_resource, _error, _message, _backtrace) do
    :ok
  end

  def _set_sample_data(_transaction_resource, _key, _payload) do
    :ok
  end

  def _set_action(_transaction_resource, _action) do
    :ok
  end

  def _set_namespace(_transaction_resource, _action) do
    :ok
  end

  def _set_queue_start(_transaction_resource, _start) do
    :ok
  end

  def _set_meta_data(_transaction_resource, _key, _value) do
    :ok
  end

  def _finish(_transaction_resource) do
    # Using `String.to_atom("no_sample") instead of `:no_sample` to trick
    # Dialyzer into thinking this value isn't hardcoded.
    String.to_atom("no_sample")
  end

  def _complete(_transaction_resource) do
    :ok
  end

  def _set_gauge(_key, _value, _tags) do
    :ok
  end

  def _increment_counter(_key, _count, _tags) do
    :ok
  end

  def _add_distribution_value(_key, _value, _tags) do
    :ok
  end

  def _data_map_new do
    {:ok, nil}
  end

  def _data_set_string(resource, _key, _value) do
    resource
  end

  def _data_set_string(resource, _value) do
    resource
  end

  def _data_set_integer(resource, _key, _value) do
    resource
  end

  def _data_set_integer(resource, _value) do
    resource
  end

  def _data_set_float(resource, _key, _value) do
    resource
  end

  def _data_set_float(resource, _value) do
    resource
  end

  def _data_set_boolean(resource, _key, _value) do
    resource
  end

  def _data_set_boolean(resource, _value) do
    resource
  end

  def _data_set_nil(resource, _key) do
    resource
  end

  def _data_set_nil(resource) do
    resource
  end

  def _data_set_data(resource, _key, _value) do
    resource
  end

  def _data_set_data(resource, _value) do
    resource
  end

  def _data_list_new do
    {:ok, nil}
  end

  def _running_in_container do
    false
  end

  def _loaded do
    false
  end

  def _trace_id(reference) do
    {:ok, 'trace123'}
  end

  def _span_id(reference) do
    {:ok, 'span123'}
  end

  def _create_root_span(name) do
    {:ok, make_ref()}
  end

  def _create_child_span(trace_id, span_id, name) do
    {:ok, make_ref()}
  end

  def _set_span_attribute_string(reference, key, value) do
    :ok
  end

  def _close_span(reference) do
    :ok
  end

  if Mix.env() in [:test, :test_phoenix, :test_no_nif] do
    def _data_to_json(resource) do
      resource
    end

    def _transaction_to_json(resource) do
      {:ok, resource}
    end
  end
end
