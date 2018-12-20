defmodule Appsignal.ErrorTest do
  use ExUnit.Case, async: true
  alias Appsignal.Error

  describe "for a RuntimeError" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          raise "Exception!"
        end)

      {exception, stacktrace} = Error.normalize(error, stack)

      [
        error: error,
        stack: stack,
        exception: exception,
        stacktrace: stacktrace,
        metadata: Error.metadata(exception)
      ]
    end

    test "returns the unchanged exception", %{error: error, exception: exception} do
      assert exception == error
    end

    test "returns the unchanged stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end

    test "extracts the error's name", %{metadata: {name, _message}} do
      assert name == "RuntimeError"
    end

    test "extracts the error's message", %{metadata: {_name, message}} do
      assert message == "Exception!"
    end
  end

  describe "for a FunctionClauseError" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          Float.ceil(1)
        end)

      {exception, stacktrace} = Error.normalize(error, stack)

      [
        stack: stack,
        exception: exception,
        stacktrace: stacktrace,
        metadata: Error.metadata(exception)
      ]
    end

    test "converts to a FunctionClauseError", %{exception: exception} do
      assert %FunctionClauseError{arity: 2, function: :ceil, module: Float} = exception
    end

    test "returns the unchanged stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end

    test "extracts the error's message", %{metadata: {_name, message}} do
      assert message == "no function clause matching in Float.ceil/2"
    end
  end

  describe "for a :timeout" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)
        end)

      {exception, stacktrace} = Error.normalize(error, stack)

      [
        stack: stack,
        exception: exception,
        stacktrace: stacktrace,
        metadata: Error.metadata(exception)
      ]
    end

    test "converts to an ErlangError", %{exception: exception} do
      assert %ErlangError{original: {:timeout, _}} = exception
    end

    test "returns the unchanged stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end

    test "extracts the error's name", %{metadata: {name, _message}} do
      assert name == ":timeout"
    end
  end

  describe "for an exit" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          exit(:exited)
        end)

      {exception, _stacktrace} = Error.normalize(error, stack)

      [
        exception: exception,
        metadata: Error.metadata(exception)
      ]
    end

    test "converts to an ErlangError", %{exception: exception} do
      assert %ErlangError{original: :exited} = exception
    end

    test "extracts the error's name", %{metadata: {name, _message}} do
      assert name == ":exited"
    end
  end

  describe "for an exception in a 2-tuple" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          try do
            raise("Exception!")
          catch
            :error, reason ->
              stack = System.stacktrace()
              exception = Exception.normalize(:error, reason, stack)
              exit({exception, stack})
          end
        end)

      {exception, stacktrace} = Error.normalize(error, stack)
      {_, nested_stack} = error

      [
        stack: nested_stack,
        exception: exception,
        stacktrace: stacktrace
      ]
    end

    test "converts to a RuntimeError", %{exception: exception} do
      assert %RuntimeError{message: "Exception!"} = exception
    end

    test "returns the nested stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end
  end

  describe "for an exit with a wrapped exception" do
    setup do
      {error, stack} =
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

      {exception, stacktrace} = Error.normalize(error, stack)
      {{_, nested_stack}, _} = error

      [
        stack: nested_stack,
        exception: exception,
        stacktrace: stacktrace
      ]
    end

    test "converts to a RuntimeError", %{exception: exception} do
      assert %RuntimeError{message: "Exception!"} = exception
    end

    test "returns the nested stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end
  end

  describe "for a nested error from an error report" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          Float.ceil(1)
        end)

      {exception, stacktrace} = Error.normalize(error, stack)

      [
        stack: stack,
        exception: exception,
        stacktrace: stacktrace
      ]
    end

    test "converts to a FunctionClauseError", %{exception: exception} do
      assert %FunctionClauseError{arity: 2, function: :ceil, module: Float} = exception
    end

    test "returns the unchanged stacktrace", %{stack: stack, stacktrace: stacktrace} do
      assert stacktrace == stack
    end
  end

  describe "for a Plug.Conn.WrapperError" do
    setup do
      {error, stack} =
        catch_error_and_stacktrace(fn ->
          raise %Plug.Conn.WrapperError{kind: :error, reason: :undef, stack: []}
        end)

      {exception, _stacktrace} = Error.normalize(error, stack)

      [exception: exception]
    end

    test "converts to an UndefinedFunctionError", %{exception: exception} do
      assert %UndefinedFunctionError{
               arity: 0,
               function: :"-__ex_unit_setup_7/1-fun-0-",
               module: Appsignal.ErrorTest
             } = exception
    end
  end

  defp catch_error_and_stacktrace(fun) do
    try do
      fun.()
    catch
      _kind, reason -> {reason, System.stacktrace()}
    end
  end
end
