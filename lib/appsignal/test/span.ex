defmodule Appsignal.Test.Span do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Span

  def create_root(namespace, pid) do
    add(:create_root, {namespace, pid})
    Span.create_root(namespace, pid)
  end

  def add_error(span, exception, stacktrace) do
    add(:add_error, {span, exception, stacktrace})
    Span.add_error(span, exception, stacktrace)
  end

  def add_error(span, kind, reason, stacktrace) do
    add(:add_error, {span, kind, reason, stacktrace})
    Span.add_error(span, kind, reason, stacktrace)
  end

  def set_name(span, name) do
    add(:set_name, {span, name})
    Span.set_name(span, name)
  end

  def set_name_if_nil(span, name) do
    add(:set_name_if_nil, {span, name})
    Span.set_name_if_nil(span, name)
  end

  def set_namespace(span, name) do
    add(:set_namespace, {span, name})
    Span.set_namespace(span, name)
  end

  def set_namespace_if_nil(span, name) do
    add(:set_namespace_if_nil, {span, name})
    Span.set_namespace_if_nil(span, name)
  end

  def set_sample_data(span, key, value) do
    add(:set_sample_data, {span, key, value})
    Span.set_sample_data(span, key, value)
  end

  def set_sample_data_if_nil(span, key, value) do
    add(:set_sample_data_if_nil, {span, key, value})
    Span.set_sample_data_if_nil(span, key, value)
  end

  def set_attribute(span, key, value) do
    add(:set_attribute, {span, key, value})
    Span.set_attribute(span, key, value)
  end

  def set_sql(span, value) do
    add(:set_sql, {span, value})
    Span.set_sql(span, value)
  end

  def close(span) do
    add(:close, {span})
    Span.close(span)
  end
end
