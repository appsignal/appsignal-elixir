defmodule Appsignal.StacktraceTest do
  use ExUnit.Case
  alias Appsignal.Stacktrace
  require Appsignal.Stacktrace

  describe "get/0" do
    setup do
      raise "Exception!"
    catch
      :error, _ ->
        %{
          stack: Stacktrace.get()
        }
    end

    test "does not return an empty list", %{stack: stack} do
      assert length(stack) > 0
    end

    test "returns a stacktrace containing the error", %{
      stack: stack
    } do
      [{Appsignal.StacktraceTest, _, _, location} | _] = stack

      expected_location = [
        file: 'test/appsignal/stacktrace_test.exs',
        line: 8
      ]

      assert Enum.all?(expected_location, &Enum.member?(location, &1))

      # On some versions, `error_info` may not be present
      all_location = expected_location ++ [error_info: %{module: Exception}]
      assert Enum.all?(location, &Enum.member?(all_location, &1))
    end
  end

  test "formats stacktrace lines" do
    stacktrace =
      [line] = [
        {:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 317]}
      ]

    assert Stacktrace.format(stacktrace) == [
             Exception.format_stacktrace_entry(line)
           ]
  end

  test "replaces arguments with arities" do
    stacktrace = [
      {:erl_internal, :op_type, [:get_stacktrace, 0], [file: 'erl_internal.erl', line: 212]}
    ]

    [line] = Stacktrace.format(stacktrace)
    assert line =~ ~r{\(stdlib( [\w.-]+)?\) erl_internal.erl:212: :erl_internal.op_type/2}
  end

  test "handles lists of binaries" do
    stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

    assert Stacktrace.format(stacktrace) == stacktrace
  end
end
