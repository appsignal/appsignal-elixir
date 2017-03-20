defmodule Appsignal.BacktraceTest do
  use ExUnit.Case, async: true
  doctest Appsignal.Backtrace

  test "formats stacktrace lines" do
    assert Appsignal.Backtrace.from_stacktrace([
      {:erl_internal, :op_type, [:get_stacktrace, 0],
        [file: 'erl_internal.erl', line: 212]}
    ]) == ["(stdlib) erl_internal.erl:212: :erl_internal.op_type(:get_stacktrace, 0)"]
  end
end
