defmodule Appsignal.ErrorHandler.ErrorMatcherTest do
  @moduledoc """
  Covers most cases of Appsignal.ErrorHandler.match_event/1
  """

  use ExUnit.Case

  defmodule CrashingGenServer do
    use GenServer

    def start(crash_type) do
      GenServer.start(__MODULE__, [crash_type])
    end

    def init([crash_type]) do
      {:ok, crash_type, 0}
    end

    def handle_info(:timeout, :exit) do
      :erlang.exit(:crashed_gen_server_exit)
      {:noreply, nil}
    end

    def handle_info(:timeout, :throw) do
      throw(:crashed_gen_server_throw)
      {:noreply, nil}
    end

    def handle_info(:timeout, :function_error) do
      Float.ceil(1)
      {:noreply, nil}
    end
  end

  defmodule CustomErrorHandler do
    def init(_) do
      {:ok, nil}
    end

    def handle_event(event, _state) do
      {:ok, Appsignal.ErrorHandler.match_event(event)}
    end

    def handle_call(:get_matched_crash, state) do
      {:remove_handler, state}
    end
  end

  @error_handler Appsignal.ErrorHandler.ErrorMatcherTest.CustomErrorHandler

  defp get_last_crash do
    :timer.sleep(20)
    :gen_event.call(:error_logger, @error_handler, :get_matched_crash)
  end

  defp assert_crash_caught({:ok, pid}) when is_pid(pid) do
    assert_crash_caught(pid)
  end

  defp assert_crash_caught(crasher) when is_pid(crasher) do
    assert {^crasher, reason, message, stacktrace, conn} = get_last_crash()
    assert is_list(stacktrace)
    assert is_binary(reason)
    assert is_binary(message)
    assert is_nil(conn)

    for s <- stacktrace do
      assert is_binary(s)
    end

    {reason, message, stacktrace}
  end

  setup do
    :error_logger.add_report_handler(@error_handler)

    on_exit(fn ->
      :error_logger.delete_report_handler(@error_handler)
    end)

    :timer.sleep(100)
  end

  test "proc_lib.spawn + exit" do
    :proc_lib.spawn(fn ->
      exit(:crash_proc_lib_spawn)
    end)
    |> assert_crash_caught
    |> reason(":crash_proc_lib_spawn")
    |> message(~r{^(E|e)rlang error: :crash_proc_lib_spawn$})
    |> stacktrace([
      ~r{test\/appsignal\/error_handler\/error_matcher_test.exs:\d+: anonymous fn\/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ exit"?/1},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + erlang.error" do
    :proc_lib.spawn(fn ->
      :erlang.error(:crash_proc_lib_error)
    end)
    |> assert_crash_caught
    |> reason(":crash_proc_lib_error")
    |> message(~r{^(E|e)rlang error: :crash_proc_lib_error$})
    |> stacktrace([
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ erlang.error"?/1},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + function error" do
    :proc_lib.spawn(fn ->
      Float.ceil(1)
    end)
    |> assert_crash_caught
    |> reason("FunctionClauseError")
    |> message("no function clause matching in Float.ceil/2")
    |> stacktrace([
      ~r{\(elixir\) lib/float.ex:\d+: Float.ceil/2},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + badmatch error" do
    :proc_lib.spawn(fn -> throw({:badmatch, [1, 2, 3]}) end)
    |> assert_crash_caught
    |> reason("MatchError")
    |> message("no match of right hand side value: [1, 2, 3]")
    |> stacktrace([
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ badmatch error"?/1},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "Crashing GenServer with throw" do
    result =
      CrashingGenServer.start(:throw)
      |> assert_crash_caught
      # http://erlang.org/pipermail/erlang-bugs/2012-April/002862.html
      |> reason(":bad_return_value")
      |> message(~r{^(E|e)rlang error: {:bad_return_valu...})

    if System.otp_release() >= "20" do
      stacktrace(result, [
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.handle_common_reply/8},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      stacktrace(result, [
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.terminate/7},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Crashing GenServer with exit" do
    result =
      CrashingGenServer.start(:exit)
      |> assert_crash_caught
      |> reason(":crashed_gen_server_exit")
      |> message(~r{^(E|e)rlang error: :crashed_gen_server_exit$})

    if System.otp_release() >= "20" do
      stacktrace(result, [
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.handle_msg/6},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      stacktrace(result, [
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.terminate/7},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Crashing GenServer with function error" do
    result =
      CrashingGenServer.start(:function_error)
      |> assert_crash_caught
      |> reason("FunctionClauseError")
      |> message("no function clause matching in Float.ceil/2")

    if System.otp_release() >= "20" do
      stacktrace(result, [
        ~r{\(elixir\) lib/float.ex:\d+: Float.ceil/2},
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.handle_msg/6},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      stacktrace(result, [
        ~r{\(elixir\) lib/float.ex:\d+: Float.ceil/2},
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.handle_msg/5},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Task" do
    result =
      Task.start(fn ->
        Float.ceil(1)
      end)
      |> assert_crash_caught
      |> reason("FunctionClauseError")
      |> stacktrace([
        ~r{\(elixir\) lib/float.ex:\d+: Float.ceil/2},
        ~r{\(elixir\) lib/task/supervised.ex:\d+: Task.Supervised.do_apply/2},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])

    message(result, "no function clause matching in Float.ceil/2")
  end

  test "Task await" do
    :proc_lib.spawn(fn ->
      Task.async(fn ->
        Process.sleep(2)
      end)
      |> Task.await(1)
    end)
    |> assert_crash_caught
    |> reason(":timeout")
    |> message(~r{^(E|e)rlang error: {:timeout, {Task, :await, \[%Tas...})
    |> stacktrace([
      ~r{\(elixir\) lib/task.ex:\d+: Task.await/2},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "Plug.Conn.WrapperError" do
    :proc_lib.spawn(fn ->
      try do
        raise %UndefinedFunctionError{}
      catch
        kind, reason ->
          raise(%Plug.Conn.WrapperError{reason: reason, kind: kind, stack: System.stacktrace()})
      end
    end)
    |> assert_crash_caught
    |> reason("UndefinedFunctionError")
    |> message(~r{^undefined function$})
    |> stacktrace([
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test Plug.Conn.WrapperError"?/1},
      ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  defp reason({reason, _message, _stacktrace} = data, expected) do
    assert expected == reason
    data
  end

  defp message({_reason, message, _stacktrace} = data, expected) when is_binary(expected) do
    assert message == expected
    data
  end

  defp message({_reason, message, _stacktrace} = data, expected) do
    assert message =~ expected
    data
  end

  defp stacktrace({_reason, _message, stacktrace} = data, expected) do
    assert_stacktrace(stacktrace, expected)
    data
  end

  defp assert_stacktrace([line | tail], [expected | expected_tail]) do
    assert line =~ expected
    assert_stacktrace(tail, expected_tail)
  end

  defp assert_stacktrace([line], [expected]), do: assert(line =~ expected)
  defp assert_stacktrace([], []), do: true
end
