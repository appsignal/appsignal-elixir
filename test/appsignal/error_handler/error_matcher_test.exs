defmodule Appsignal.ErrorHandler.ErrorMatcherTest do
  @moduledoc """
  Covers most cases of Appsignal.ErrorHandler.match_event/1
  """

  alias Appsignal.FakeTransaction
  import AppsignalTest.Utils
  use ExUnit.Case

  # Monitoring processes can be delayed by a little bit since
  # `Process.monitor/1` which is called internally is asynchronous and can take
  # a tiny bit to actually start monitoring. Instead, we sleep for a little bit
  # to allow the Receiver to establish a monitor before testing for errors. This
  # is not as big of an issue in OTP 19 & 20, but more prevalent in OTP 21 & 22.
  @process_monitor_delay 10

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

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "proc_lib.spawn + exit", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      exit(:crash_proc_lib_spawn)
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == ":crash_proc_lib_spawn"
    assert message =~ ~r{^(E|e)rlang error: :crash_proc_lib_spawn$}

    assert_stacktrace(stacktrace, [
      ~r{test\/appsignal\/error_handler\/error_matcher_test.exs:\d+: anonymous fn\/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ exit"?/1},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + erlang.error", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      :erlang.error(:crash_proc_lib_error)
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == ":crash_proc_lib_error"
    assert message =~ ~r{^(E|e)rlang error: :crash_proc_lib_error$}

    assert_stacktrace(stacktrace, [
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ erlang.error"?/1},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + function error", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      Float.ceil(1)
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == "FunctionClauseError"
    assert message == "no function clause matching in Float.ceil/2"

    assert_stacktrace(stacktrace, [
      ~r{\(elixir( [\w.-]+)?\) lib/float.ex:\d+: Float.ceil/2},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "proc_lib.spawn + badmatch error", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn -> throw({:badmatch, [1, 2, 3]}) end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == "MatchError"
    assert message == "no match of right hand side value: [1, 2, 3]"

    assert_stacktrace(stacktrace, [
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test proc_lib.spawn \+ badmatch error"?/1},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "Crashing GenServer with throw", %{fake_transaction: fake_transaction} do
    CrashingGenServer.start(:throw)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == ":bad_return_value"
    assert message =~ ~r{^(E|e)rlang error: {:bad_return_valu...}

    if System.otp_release() >= "20" do
      assert_stacktrace(stacktrace, [
        ~r{\(stdlib( [\w.-]+)?\) gen_server.erl:\d+: :gen_server.handle_common_reply/8},
        ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      assert_stacktrace(stacktrace, [
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.terminate/7},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Crashing GenServer with exit", %{fake_transaction: fake_transaction} do
    CrashingGenServer.start(:exit)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == ":crashed_gen_server_exit"
    assert message =~ ~r{^(E|e)rlang error: :crashed_gen_server_exit$}

    if System.otp_release() >= "20" do
      assert_stacktrace(stacktrace, [
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib( [\w.-]+)?\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib( [\w.-]+)?\) gen_server.erl:\d+: :gen_server.handle_msg/6},
        ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      assert_stacktrace(stacktrace, [
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.terminate/7},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Crashing GenServer with function error", %{fake_transaction: fake_transaction} do
    CrashingGenServer.start(:function_error)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == "FunctionClauseError"
    assert message == "no function clause matching in Float.ceil/2"

    if System.otp_release() >= "20" do
      assert_stacktrace(stacktrace, [
        ~r{\(elixir( [\w.-]+)?\) lib/float.ex:\d+: Float.ceil/2},
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib( [\w.-]+)?\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib( [\w.-]+)?\) gen_server.erl:\d+: :gen_server.handle_msg/6},
        ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    else
      assert_stacktrace(stacktrace, [
        ~r{\(elixir\) lib/float.ex:\d+: Float.ceil/2},
        ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: Appsignal.ErrorHandler.ErrorMatcherTest.CrashingGenServer.handle_info/2},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.try_dispatch/4},
        ~r{\(stdlib\) gen_server.erl:\d+: :gen_server.handle_msg/5},
        ~r{\(stdlib\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
      ])
    end
  end

  test "Task", %{fake_transaction: fake_transaction} do
    Task.start(fn ->
      Float.ceil(1)
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == "FunctionClauseError"
    assert message == "no function clause matching in Float.ceil/2"

    assert_stacktrace(stacktrace, [
      ~r{\(elixir( [\w.-]+)?\) lib/float.ex:\d+: Float.ceil/2},
      ~r{\(elixir( [\w.-]+)?\) lib/(task/)?supervised.ex:\d+: Task.Supervised\.\w+/2},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p_do_apply/3}
    ])
  end

  test "Task await", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      Task.async(fn ->
        Process.sleep(2)
      end)
      |> Task.await(1)
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == ":timeout"
    assert message =~ ~r{^(E|e)rlang error: {:timeout, {Task, :await, \[%Tas...}

    assert_stacktrace(stacktrace, [
      ~r{\(elixir( [\w.-]+)?\) lib/task.ex:\d+: Task.await/2},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  test "Plug.Conn.WrapperError", %{fake_transaction: fake_transaction} do
    :proc_lib.spawn(fn ->
      try do
        raise %UndefinedFunctionError{}
      catch
        kind, reason ->
          raise(%Plug.Conn.WrapperError{reason: reason, kind: kind, stack: System.stacktrace()})
      end
    end)

    Process.sleep(@process_monitor_delay)

    [{_, reason, message, stacktrace}] =
      until(fn ->
        assert [{_, _, _, _}] = FakeTransaction.errors(fake_transaction)
      end)

    assert reason == "UndefinedFunctionError"
    assert message == "undefined function"

    assert_stacktrace(stacktrace, [
      ~r{test/appsignal/error_handler/error_matcher_test.exs:\d+: anonymous fn/0 in Appsignal.ErrorHandler.ErrorMatcherTest."?test Plug.Conn.WrapperError"?/1},
      ~r{\(stdlib( [\w.-]+)?\) proc_lib.erl:\d+: :proc_lib.init_p/3}
    ])
  end

  defp assert_stacktrace([line | tail], [expected | expected_tail]) do
    assert line =~ expected
    assert_stacktrace(tail, expected_tail)
  end

  defp assert_stacktrace([line], [expected]), do: assert(line =~ expected)
  defp assert_stacktrace([], []), do: true
end
