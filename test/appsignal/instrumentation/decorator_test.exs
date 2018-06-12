defmodule UsingAppsignalDecorators do
  use Appsignal.Instrumentation.Decorators

  @decorate transaction()
  def transaction do
    bar(123)
  end

  @decorate transaction(:background_job)
  def background_transaction do
    bar(123)
  end

  @decorate transaction()
  def transaction_with_return_value(x) do
    2 * x
  end

  @decorate transaction_event()
  def bar(arg) do
    nested(arg, arg)
  end

  @doc "A moduledoc attribute"
  @decorate transaction_event()
  def nested(_arg1, _arg2) do
  end
end

defmodule UsingAppsignalDecoratorsWithCustomNamespaces do
  use Appsignal.Instrumentation.Decorators

  @doc "A moduledoc attribute"
  @decorate transaction_event :http
  def bar(arg) do
    nested(arg, arg)
  end

  @decorate transaction_event :db
  def nested(_arg1, _arg2) do
  end
end

defmodule Appsignal.Instrumentation.DecoratorsTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.Transaction

  test_with_mock "instrument module function", Appsignal.Transaction, [:passthrough], [] do
    Transaction.start("bar", :http_request)
    UsingAppsignalDecorators.bar(123)
    assert called Transaction.start_event(:_)
    assert called Transaction.finish_event(:_, "bar", "Elixir.UsingAppsignalDecorators.bar", "", 0)
    assert called Transaction.finish_event(:_, "nested", "Elixir.UsingAppsignalDecorators.nested", "", 0)
  end

  test_with_mock "instrument transaction", Appsignal.Transaction, [:passthrough], [] do
    UsingAppsignalDecorators.transaction
    assert called Transaction.start(:_, :http_request)
    assert called Appsignal.Transaction.set_action(:_, "Elixir.UsingAppsignalDecorators#transaction")
    assert called Appsignal.Transaction.finish(:_)
    assert called Appsignal.Transaction.complete(:_)
  end

  test_with_mock "instrument background transaction", Appsignal.Transaction, [:passthrough], [] do
    UsingAppsignalDecorators.background_transaction
    assert called Transaction.start(:_, :background_job)
    assert called Appsignal.Transaction.set_action(:_, "Elixir.UsingAppsignalDecorators#background_transaction")
    assert called Appsignal.Transaction.finish(:_)
    assert called Appsignal.Transaction.complete(:_)
  end

  test_with_mock "instrument transaction with return value", Appsignal.Transaction, [:passthrough], [] do
    result = UsingAppsignalDecorators.transaction_with_return_value(123)
    assert 246 == result
    assert called Transaction.start(:_, :http_request)
    assert called Appsignal.Transaction.set_action(:_, "Elixir.UsingAppsignalDecorators#transaction_with_return_value")
    assert called Appsignal.Transaction.finish(:_)
    assert called Appsignal.Transaction.complete(:_)
  end


  test_with_mock "instrument module function with category", Appsignal.Transaction, [:passthrough], [] do
    Transaction.start("bar", :http_request)
    UsingAppsignalDecoratorsWithCustomNamespaces.bar(123)
    assert called Transaction.start_event(:_)
    assert called Transaction.finish_event(:_, "bar.http", "Elixir.UsingAppsignalDecoratorsWithCustomNamespaces.bar", "", 0)
    assert called Transaction.finish_event(:_, "nested.db", "Elixir.UsingAppsignalDecoratorsWithCustomNamespaces.nested", "", 0)
  end

end
