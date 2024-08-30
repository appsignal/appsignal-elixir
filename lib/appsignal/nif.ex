defmodule Appsignal.NifBehaviour do
  @moduledoc false
  @callback loaded?() :: boolean()
  @callback running_in_container?() :: boolean()
end

defmodule Appsignal.Nif do
  @behaviour Appsignal.NifBehaviour
  @moduledoc false

  @on_load :init

  def init do
    path = :filename.join(:code.priv_dir(:appsignal), ~c"appsignal_extension")

    case :erlang.load_nif(path, 1) do
      :ok ->
        :ok

      {:error, {:load_failed, reason}} ->
        arch = :erlang.system_info(:system_architecture)

        IO.warn(
          "Error loading NIF (Is your operating system (#{arch}) supported? Please check http://docs.appsignal.com/support/operating-systems.html):\n#{reason}"
        )

        :ok
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

  def create_root_span(namespace) do
    _create_root_span(namespace)
  end

  def create_root_span_with_timestamp(namespace, sec, nsec) do
    _create_root_span_with_timestamp(namespace, sec, nsec)
  end

  def create_child_span(parent) do
    _create_child_span(parent)
  end

  def create_child_span_with_timestamp(parent, sec, nsec) do
    _create_child_span_with_timestamp(parent, sec, nsec)
  end

  def set_span_name(reference, name) do
    _set_span_name(reference, name)
  end

  def set_span_name_if_nil(reference, name) do
    _set_span_name_if_nil(reference, name)
  end

  def set_span_namespace(reference, namespace) do
    _set_span_namespace(reference, namespace)
  end

  def set_span_attribute_string(reference, key, value) do
    _set_span_attribute_string(reference, key, value)
  end

  def set_span_attribute_int(reference, key, value) do
    _set_span_attribute_int(reference, key, value)
  end

  def set_span_attribute_bool(reference, key, value) do
    _set_span_attribute_bool(reference, key, value)
  end

  def set_span_attribute_double(reference, key, value) do
    _set_span_attribute_double(reference, key, value)
  end

  def set_span_attribute_sql_string(reference, key, value) do
    _set_span_attribute_sql_string(reference, key, value)
  end

  def set_span_sample_data(reference, key, value) do
    _set_span_sample_data(reference, key, value)
  end

  def set_span_sample_data_if_nil(reference, key, value) do
    _set_span_sample_data_if_nil(reference, key, value)
  end

  def add_span_error(reference, name, message, backtrace) do
    _add_span_error(reference, name, message, backtrace)
  end

  def close_span(reference) do
    _close_span(reference)
  end

  def close_span_with_timestamp(reference, sec, nsec) do
    _close_span_with_timestamp(reference, sec, nsec)
  end

  def span_to_json(resource) do
    _span_to_json(resource)
  end

  def log(group, severity, format, message, attributes) do
    _log(group, severity, format, message, attributes)
  end

  if Mix.env() == :test do
    def data_to_json(reference) do
      _data_to_json(reference)
    end
  end

  def _env_put(_key, _value) do
    :ok
  end

  def _env_get(_key) do
    ~c""
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

  def _create_root_span(_namespace) do
    {:ok, make_ref()}
  end

  def _create_root_span_with_timestamp(_namespace, _sec, _nsec) do
    {:ok, make_ref()}
  end

  def _create_child_span(_parent) do
    {:ok, make_ref()}
  end

  def _create_child_span_with_timestamp(_parent, _sec, _nsec) do
    {:ok, make_ref()}
  end

  def _set_span_name(_reference, _name) do
    :ok
  end

  def _set_span_name_if_nil(_reference, _name) do
    :ok
  end

  def _set_span_namespace(_reference, _namespace) do
    :ok
  end

  def _set_span_attribute_string(_reference, _key, _value) do
    :ok
  end

  def _set_span_attribute_int(_reference, _key, _value) do
    :ok
  end

  def _set_span_attribute_bool(_reference, _key, _value) do
    :ok
  end

  def _set_span_attribute_double(_reference, _key, _value) do
    :ok
  end

  def _set_span_attribute_sql_string(_reference, _key, _value) do
    :ok
  end

  def _set_span_sample_data(_reference, _key, _value) do
    :ok
  end

  def _set_span_sample_data_if_nil(_reference, _key, _value) do
    :ok
  end

  def _add_span_error(_reference, _name, _message, _backtrace) do
    :ok
  end

  def _close_span(_reference) do
    :ok
  end

  def _close_span_with_timestamp(_reference, _sec, _nsec) do
    :ok
  end

  def _span_to_json(_reference) do
    {:ok, "{}"}
  end

  def _log(_group, _severity, _format, _message, _attributes) do
    :ok
  end

  if Mix.env() in [:test, :test_no_nif] do
    def _data_to_json(resource) do
      resource
    end
  end
end
