defmodule Appsignal.ErrorTest do
  use ExUnit.Case

  describe "metadata/3, with an exception" do
    setup do
      try do
        raise "Exception!"
      catch
        kind, reason -> %{metadata: Appsignal.Error.metadata(kind, reason, __STACKTRACE__)}
      end
    end

    test "extracts the error's name", %{metadata: metadata} do
      assert {"RuntimeError", _message, _stack} = metadata
    end

    test "extracts the error's message", %{metadata: metadata} do
      assert {_name, "** (RuntimeError) Exception!", _stack} = metadata
    end

    test "format's the error's stack trace", %{metadata: metadata} do
      {_name, _message, stack} = metadata
      assert is_list(stack)
      assert length(stack) > 0
      assert Enum.all?(stack, &is_binary(&1))
    end
  end

  describe "metadata/3, with a badarg" do
    setup do
      try do
        _ = String.to_integer("one")
      catch
        kind, reason -> %{metadata: Appsignal.Error.metadata(kind, reason, __STACKTRACE__)}
      end
    end

    test "extracts the error's name", %{metadata: metadata} do
      assert {"ArgumentError", _message, _stack} = metadata
    end

    test "extracts the error's message", %{metadata: metadata} do
      assert {_name, "** (ArgumentError) argument error", _stack} = metadata
    end

    test "format's the error's stack trace", %{metadata: metadata} do
      {_name, _message, stack} = metadata
      assert is_list(stack)
      assert length(stack) > 0
      assert Enum.all?(stack, &is_binary(&1))
    end
  end
end
