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

    test "formats stacktrace lines", %{stack: stack} do
      [line | _] = stack
      assert Stacktrace.format([line]) == [Exception.format_stacktrace_entry(line)]
    end
  end

  describe "get/0, with an exception with included arguments" do
    setup do
      String.to_atom("string", :extra_argument, 123, :erlang.list_to_pid('<0.0.0>'))
    catch
      :error, _ -> %{stack: Stacktrace.get()}
    end

    test "replaces sensitive arguments with types", %{stack: stack} do
      [line | _] = Stacktrace.format(stack)
      assert line =~ ~r{\(elixir( [\w.-]+)?\) String.to_atom\(binary, atom, 123, #PID<0.0.0>\)}
    end
  end

  test "handles lists of binaries" do
    stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

    assert Stacktrace.format(stacktrace) == stacktrace
  end
end
