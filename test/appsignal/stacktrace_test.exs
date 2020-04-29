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
          stack: Stacktrace.get(),
          system_stacktrace: System.stacktrace()
        }
    end

    test "returns the stacktrace", %{
      stack: stack,
      system_stacktrace: system_stacktrace
    } do
      assert stack == system_stacktrace
    end

    test "does not return an empty list", %{stack: stack} do
      assert length(stack) > 0
    end
  end
end
