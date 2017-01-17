defmodule Appsignal.Instrumentation.DecoratorsTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.Transaction

  defmodule Example do
    use Appsignal.Instrumentation.Decorators

    @decorate transaction
    def transaction do
      bar(123)
    end

    @decorate transaction(:background_job)
    def background_transaction do
      bar(123)
    end

    @decorate transaction_event
    def bar(arg) do
      nested(arg, arg)
    end

    @doc "A moduledoc attribute"
    @decorate transaction_event
    def nested(_arg1, _arg2) do
    end

  end

  test_with_mock "instrument module function", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("bar", :http_request)
    Example.bar(123)
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "bar", "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example.bar", "", 0)
    assert called Transaction.finish_event(t, "nested", "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example.nested", "", 0)
  end

  test_with_mock "instrument transaction", Appsignal.Transaction, [:passthrough], [] do
    Example.transaction
    assert called Transaction.start(:_, :http_request)
    assert called Appsignal.Transaction.set_action(:_, "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example#transaction")
    assert called Appsignal.Transaction.finish(:_)
    assert called Appsignal.Transaction.complete(:_)
  end

  test_with_mock "instrument background transaction", Appsignal.Transaction, [:passthrough], [] do
    Example.background_transaction
    assert called Transaction.start(:_, :background_job)
    assert called Appsignal.Transaction.set_action(:_, "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example#background_transaction")
    assert called Appsignal.Transaction.finish(:_)
    assert called Appsignal.Transaction.complete(:_)
  end

  defmodule Example2 do
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

  test_with_mock "instrument module function with category", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("bar", :http_request)
    Example2.bar(123)
    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "bar.http", "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example2.bar", "", 0)
    assert called Transaction.finish_event(t, "nested.db", "Elixir.Appsignal.Instrumentation.DecoratorsTest.Example2.nested", "", 0)
  end

end
