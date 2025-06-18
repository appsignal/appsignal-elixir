defmodule Appsignal.Test.Nif do
  use Appsignal.Test.Wrapper
  alias Appsignal.Nif

  def create_root_span(namespace) do
    add(:create_root_span, {namespace})
    Nif.create_root_span(namespace)
  end

  def create_root_span_with_timestamp(namespace, sec, nsec) do
    add(:create_root_span_with_timestamp, {namespace, sec, nsec})
    Nif.create_root_span_with_timestamp(namespace, sec, nsec)
  end

  def create_child_span(parent) do
    add(:create_child_span, {parent})
    Nif.create_child_span(parent)
  end

  def create_child_span_with_timestamp(parent, sec, nsec) do
    add(:create_child_span_with_timestamp, {parent, sec, nsec})
    Nif.create_child_span_with_timestamp(parent, sec, nsec)
  end

  def set_span_name(reference, name) do
    add(:set_span_name, {reference, name})
    Nif.set_span_name(reference, name)
  end

  def set_span_name_if_nil(reference, name) do
    add(:set_span_name_if_nil, {reference, name})
    Nif.set_span_name_if_nil(reference, name)
  end

  def set_span_namespace(reference, namespace) do
    add(:set_span_namespace, {reference, namespace})
    Nif.set_span_namespace(reference, namespace)
  end

  def add_span_error(reference, name, message, stacktrace) do
    add(:add_span_error, {reference, name, message, stacktrace})
    Nif.add_span_error(reference, name, message, stacktrace)
  end

  def set_span_attribute_string(span, key, value) do
    add(:set_span_attribute_string, {span, key, value})
    Nif.set_span_attribute_string(span, key, value)
  end

  def set_span_attribute_int(span, key, value) do
    add(:set_span_attribute_int, {span, key, value})
    Nif.set_span_attribute_int(span, key, value)
  end

  def set_span_attribute_bool(span, key, value) do
    add(:set_span_attribute_bool, {span, key, value})
    Nif.set_span_attribute_bool(span, key, value)
  end

  def set_span_attribute_double(span, key, value) do
    add(:set_span_attribute_double, {span, key, value})
    Nif.set_span_attribute_double(span, key, value)
  end

  def set_span_attribute_sql_string(span, key, value) do
    add(:set_span_attribute_sql_string, {span, key, value})
    Nif.set_span_attribute_sql_string(span, key, value)
  end

  def set_span_sample_data(span, key, value) do
    add(:set_span_sample_data, {span, key, value})
    Nif.set_span_sample_data(span, key, value)
  end

  def set_span_sample_data_if_nil(span, key, value) do
    add(:set_span_sample_data_if_nil, {span, key, value})
    Nif.set_span_sample_data_if_nil(span, key, value)
  end

  def close_span(reference) do
    add(:close_span, {reference})
    Nif.close_span(reference)
  end

  def close_span_with_timestamp(reference, sec, nsec) do
    add(:close_span_with_timestamp, {reference, sec, nsec})
    Nif.close_span_with_timestamp(reference, sec, nsec)
  end

  def log(group, severity, format, message, metadata) do
    add(:log, {group, severity, format, message, metadata})
    Nif.log(group, severity, format, message, metadata)
  end
end
