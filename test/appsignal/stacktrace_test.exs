defmodule Appsignal.StacktraceTest do
  use ExUnit.Case
  alias Appsignal.Stacktrace

  describe "format/1" do
    setup do
      raise "Exception!"
    catch
      :error, _ ->
        %{
          stack: __STACKTRACE__
        }
    end

    test "formats stacktrace lines", %{stack: stack} do
      [line | _] = stack
      assert Stacktrace.format([line]) == [Exception.format_stacktrace_entry(line)]
    end

    test "handles lists of binaries" do
      stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

      assert Stacktrace.format(stacktrace) == stacktrace
    end

    test "does not handle non-lists" do
      assert Stacktrace.format(
               {:gen_server, :call, [:image_magick_pool, {:checkout, self(), true}, 5000]}
             ) == []
    end
  end

  describe "format/1, with an exception with included arguments" do
    setup do
      String.to_atom("string", :extra_argument, 123, :erlang.list_to_pid(~c"<0.0.0>"))
    catch
      :error, _ -> %{stack: __STACKTRACE__}
    end

    test "replaces sensitive arguments with types", %{stack: stack} do
      [line | _] = Stacktrace.format(stack)

      assert line =~
               ~r{\(elixir( [\w.-]+)?\) String.to_atom\("\.\.\.", :extra_argument, integer\(\), #PID<\.\.\.>\)}
    end
  end
end
