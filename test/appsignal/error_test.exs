defmodule Appsignal.ErrorTest do
  use ExUnit.Case

  describe "metadata/2, with an exception" do
    setup do
      try do
        raise "Exception!"
      rescue
        exception -> %{metadata: Appsignal.Error.metadata(exception, __STACKTRACE__)}
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
      refute Enum.empty?(stack)
      assert Enum.all?(stack, &is_binary(&1))
    end
  end

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
      refute Enum.empty?(stack)
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
      {_name, error_message, _stack} = metadata

      assert String.match?(error_message, ~r/(ArgumentError)/)
    end

    test "format's the error's stack trace", %{metadata: metadata} do
      {_name, _message, stack} = metadata
      assert is_list(stack)
      refute Enum.empty?(stack)
      assert Enum.all?(stack, &is_binary(&1))
    end
  end

  describe "metadata/3, with a function_clause" do
    setup do
      try do
        _ = Keyword.get(:a, :b)
      catch
        kind, reason -> %{metadata: Appsignal.Error.metadata(kind, reason, __STACKTRACE__)}
      end
    end

    test "extracts the error's name", %{metadata: metadata} do
      assert {"FunctionClauseError", _message, _stack} = metadata
    end

    test "extracts the error's message", %{metadata: metadata} do
      {_name, error_message, _stack} = metadata

      assert error_message ==
               "** (FunctionClauseError) no function clause matching in Keyword.get/3"
    end

    test "format's the error's stack trace", %{metadata: metadata} do
      {_name, _message, stack} = metadata
      assert is_list(stack)
      refute Enum.empty?(stack)
      assert Enum.all?(stack, &is_binary(&1))
    end
  end

  describe "metadata/3, with an exit" do
    setup do
      try do
        exit(:exited)
      catch
        kind, reason -> %{metadata: Appsignal.Error.metadata(kind, reason, __STACKTRACE__)}
      end
    end

    test "extracts the error's name", %{metadata: metadata} do
      assert {":exit", _message, _stack} = metadata
    end

    test "extracts the error's message", %{metadata: metadata} do
      assert {_name, "** (exit) :exited", _stack} = metadata
    end

    test "format's the error's stack trace", %{metadata: metadata} do
      {_name, _message, stack} = metadata
      assert is_list(stack)
      refute Enum.empty?(stack)
      assert Enum.all?(stack, &is_binary(&1))
    end
  end
end
