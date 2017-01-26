defmodule Appsignal.Nif do
  @moduledoc """

  It's a NIF! Oh no!

  While people generally think NIFs are a bad idea, the overhead of
  this particular NIF is low. The C code that the NIF calls has been
  designed to be as fast as possible and to do as little as possible
  on the calling thread.

  Internally, the Appsignal NIF works as follows: it fork/execs a
  separate agent process, to which the NIF sends its data (protobuf)
  over a unix socket. This agent process (which is a separate unix
  process!) then takes care of sending the data the the server
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

  require Logger

  def init do
    path = :filename.join(:code.priv_dir(:appsignal), 'appsignal_extension')
    case :erlang.load_nif(path, 1) do
      :ok -> :ok
      {:error, {:load_failed, reason}} ->
        arch = :erlang.system_info(:system_architecture)
        Logger.error "Error loading NIF, Appsignal integration disabled!\n\n#{reason}\n\nIs your operating system (#{arch}) supported?\nPlease check http://docs.appsignal.com/support/operating-systems.html"
        :ok
    end
  end

  def start do
    _start()
  end

  def stop do
    _stop()
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

  def record_event(transaction_resource, name, title, body, duration, body_format) do
    _record_event(transaction_resource, name, title, body, duration, body_format)
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

  def set_gauge(key, value) do
    _set_gauge(key, value)
  end

  def increment_counter(key, count) do
    _increment_counter(key, count)
  end

  def add_distribution_value(key, value) do
    _add_distribution_value(key, value)
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

  if Mix.env in [:test, :test_phoenix] do
    def data_to_json(resource) do
      _data_to_json(resource)
    end
  end

  def data_list_new do
    _data_list_new()
  end

  def loaded? do
    _loaded()
  end

  def _start do
    :ok
  end

  def _stop do
    :ok
  end

  def _start_transaction(_id, _namespace) do
    {:ok, <<>>}
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

  def _record_event(_transaction_resource, _name, _title, _body, _duration, _body_format) do
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

  def _set_queue_start(_transaction_resource, _start) do
    :ok
  end

  def _set_meta_data(_transaction_resource, _key, _value) do
    :ok
  end

  def _finish(_transaction_resource) do
    :no_sample
  end

  def _complete(_transaction_resource) do
    :ok
  end

  def _set_gauge(_key, _value) do
    :ok
  end

  def _increment_counter(_key, _count) do
    :ok
  end

  def _add_distribution_value(_key, _value) do
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

  def _data_list_new() do
    {:ok, nil}
  end

  def _loaded do
    false
  end

  if Mix.env in [:test, :test_phoenix] do
    def _data_to_json(resource) do
      resource
    end
  end

end
