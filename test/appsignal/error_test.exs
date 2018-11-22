defmodule Appsignal.ErrorTest do
  use ExUnit.Case, async: true
  alias Appsignal.Error

  describe "for a RuntimeError" do
    setup do
      {error, stacktrace} =
        catch_error_and_stacktrace(fn ->
          raise "Exception!"
        end)

      [metadata: Error.metadata(error, stacktrace)]
    end

    test "extracts the error's name", %{metadata: {name, _message, _backtrace}} do
      assert name == "RuntimeError"
    end

    test "extracts the error's message", %{metadata: {_name, message, _backtrace}} do
      assert message == "Exception!"
    end

    test "extracts the error's backtrace", %{metadata: {_name, _message, backtrace}} do
      assert_backtrace(backtrace, [
        ~r{^test/appsignal/error_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorTest.__ex_unit_setup_0/1$},
        ~r{^test/appsignal/error_test.exs:\d+: Appsignal.ErrorTest.catch_error_and_stacktrace/1$},
        ~r{^test/appsignal/error_test.exs:\d+: Appsignal.ErrorTest.__ex_unit_setup_0/1$},
        ~r{^test/appsignal/error_test.exs:\d+: Appsignal.ErrorTest.__ex_unit__/2$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: ExUnit.Runner.exec_test_setup/2$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: anonymous fn/2 in ExUnit.Runner.spawn_test/3$},
        ~r{^\(stdlib\) timer.erl:\d+: :timer.tc/1$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: anonymous fn/4 in ExUnit.Runner.spawn_test/3$}
      ])
    end
  end

  describe "for a :timeout" do
    setup do
      {error, stacktrace} =
        catch_error_and_stacktrace(fn ->
          Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)
        end)

      [metadata: Error.metadata(error, stacktrace)]
    end

    test "extracts the error's name", %{metadata: {name, _message, _backtrace}} do
      assert name == ":timeout"
    end
  end

  describe "for an exit" do
    setup do
      {error, stacktrace} =
        catch_error_and_stacktrace(fn ->
          exit(:exited)
        end)

      [metadata: Error.metadata(error, stacktrace)]
    end

    test "extracts the error's name", %{metadata: {name, _message, _backtrace}} do
      assert name == ":exited"
    end
  end

  describe "for an exit with a wrapped exception" do
    setup do
      {error, stacktrace} =
        catch_error_and_stacktrace(fn ->
          try do
            raise("Exception!")
          catch
            :error, reason ->
              stack = System.stacktrace()
              exception = Exception.normalize(:error, reason, stack)
              exit({{exception, stack}, {}})
          end
        end)

      [metadata: Error.metadata(error, stacktrace)]
    end

    test "extracts the error's name", %{metadata: {name, _message, _backtrace}} do
      assert name == "RuntimeError"
    end
  end

  describe "for an error without an atom name" do
    test "falls back 'ErlangError' as the error's name" do
      assert {"ErlangError", _, _} = Error.metadata("string!", [])
      assert {"ErlangError", _, _} = Error.metadata({"string!", []}, [])
    end
  end

  defp catch_error_and_stacktrace(fun) do
    try do
      fun.()
    catch
      _kind, reason -> {reason, System.stacktrace()}
    end
  end

  defp assert_backtrace(actual, expected) do
    actual
    |> Enum.zip(expected)
    |> Enum.each(fn {actual, expected} ->
      assert actual =~ expected
    end)
  end
end
