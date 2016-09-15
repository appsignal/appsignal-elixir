defmodule AppsignalFunctionInstrumentationMacroTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.Transaction

  defmodule Foo do
    import Appsignal.Helpers

    instrumented do

      def bar(arg) do
        nested(arg, arg)
      end

      def nested(_arg1, _arg2) do
      end

    end
  end

  test_with_mock "instrument module function", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("bar", :http_request)

    Foo.bar(123)

    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "bar", "Elixir.AppsignalFunctionInstrumentationMacroTest.Foo.bar", "", 0)
    assert called Transaction.finish_event(t, "nested", "Elixir.AppsignalFunctionInstrumentationMacroTest.Foo.nested", "", 0)

  end


  defmodule Foo2 do
    import Appsignal.Helpers

    instrumented :http do

      def bar(arg) do
        nested(arg, arg)
      end

      def nested(_arg1, _arg2) do
      end

    end
  end

  test_with_mock "instrument module function with category", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("bar", :http_request)

    Foo2.bar(123)

    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "bar.http", "Elixir.AppsignalFunctionInstrumentationMacroTest.Foo2.bar", "", 0)
    assert called Transaction.finish_event(t, "nested.http", "Elixir.AppsignalFunctionInstrumentationMacroTest.Foo2.nested", "", 0)

  end



  defmodule Foo3 do
    import Appsignal.Helpers

    def call_it() do
      private_fun()
    end

    instrumented do

      defp private_fun() do
        123
      end

    end
  end

  test_with_mock "instrument module function with defp", Appsignal.Transaction, [:passthrough], [] do
    t = Transaction.start("foo3", :http_request)

    Foo3.call_it()

    assert called Transaction.start_event(t)
    assert called Transaction.finish_event(t, "private_fun", "Elixir.AppsignalFunctionInstrumentationMacroTest.Foo3.private_fun", "", 0)

  end

end
