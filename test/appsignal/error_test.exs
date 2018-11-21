defmodule Appsignal.ErrorTest do
  use ExUnit.Case, async: true
  alias Appsignal.Error

  describe "for a RuntimeError" do
    setup do
      {error, stacktrace} =
        try do
          raise "Exception!"
        rescue
          error -> {error, System.stacktrace()}
        end

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
        ~r{^test/appsignal/error_test.exs:\d+: Appsignal.ErrorTest.__ex_unit_setup_0/1$},
        ~r{^test/appsignal/error_test.exs:\d+: Appsignal.ErrorTest.__ex_unit__/2$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: ExUnit.Runner.exec_test_setup/2$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: anonymous fn/2 in ExUnit.Runner.spawn_test/3$},
        ~r{^\(stdlib\) timer.erl:\d+: :timer.tc/1$},
        ~r{^\(ex_unit\) lib/ex_unit/runner.ex:\d+: anonymous fn/4 in ExUnit.Runner.spawn_test/3$}
      ])
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
