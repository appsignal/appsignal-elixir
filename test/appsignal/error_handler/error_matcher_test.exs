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
      String.length(:notastring)
      {:noreply, nil}
    end
  end


  defmodule CustomErrorHandler do

    use GenEvent

    def init(_) do
      {:ok, nil}
    end

    def handle_event(event, nil) do
      {:ok, Appsignal.ErrorHandler.match_event(event)}
    end
    def handle_event(_event, state) do
      # ignore other events when we already have caught one error event
      {:ok, state}
    end

    def handle_call(:get_matched_crash, state) do
      {:remove_handler, state}
    end

  end

  @error_handler Appsignal.ErrorHandler.ErrorMatcherTest.CustomErrorHandler

  defp get_last_crash do
    :timer.sleep(20)
    GenEvent.call(:error_logger, @error_handler, :get_matched_crash)
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
      # IO.puts("- #{s}")
    end
    reason
  end


  setup do
    :error_logger.add_report_handler(@error_handler)
    on_exit(fn() ->
      :error_logger.delete_report_handler(@error_handler)
    end)
    :timer.sleep 100
  end


  test "bare spawn + throw" do
    spawn(fn() ->
      throw(:crash_bare_throw)
    end)
    |> assert_crash_caught
    |> reason("{:nocatch, :crash_bare_throw}")
  end

  test "bare spawn + :erlang.error" do
    spawn(fn() ->
      :erlang.error(:crash_bare_error)
    end)
    |> assert_crash_caught
    |> reason(":crash_bare_error")
  end

  test "bare spawn + function error" do
    spawn(fn() ->
      String.length(:notastring)
    end)
    |> assert_crash_caught
    |> reason(":function_clause")
  end

  test "bare spawn + badmatch error" do
    spawn(fn() ->
      1 = 2
    end)
    |> assert_crash_caught
    |> reason("{:badmatch, 2}")
  end



  test "proc_lib.spawn + exit" do
    :proc_lib.spawn(fn() ->
      exit(:crash_proc_lib_spawn)
    end)
    |> assert_crash_caught
    |> reason("{:exit, :crash_proc_lib_spawn}")
  end

  test "proc_lib.spawn + erlang.error" do
    :proc_lib.spawn(fn() ->
      :erlang.error(:crash_proc_lib_error)
    end)
    |> assert_crash_caught
    |> reason("{:error, :crash_proc_lib_error}")
  end

  test "proc_lib.spawn + function error" do
    :proc_lib.spawn(fn() ->
      String.length(:notastring)
    end)
    |> assert_crash_caught
    |> reason("{:error, :function_clause}")
  end

  test "proc_lib.spawn + badmatch error" do
    :proc_lib.spawn(fn() ->
      1 = 2
    end)
    |> assert_crash_caught
    |> reason("{:error, {:badmatch, 2}}")
  end


  test "Crashing GenServer with throw" do
    CrashingGenServer.start(:throw)
    |> assert_crash_caught
    # http://erlang.org/pipermail/erlang-bugs/2012-April/002862.html
    |> reason("{:bad_return_value, :crashed_gen_server_throw}")
  end

  test "Crashing GenServer with exit" do
    CrashingGenServer.start(:exit)
    |> assert_crash_caught
    |> reason(":crashed_gen_server_exit")
  end

  test "Crashing GenServer with function error" do
    CrashingGenServer.start(:function_error)
    |> assert_crash_caught
    |> reason(":function_clause")
  end

  test "Task" do
    Task.start(fn() ->
      String.length(:notastring)
    end)
    |> assert_crash_caught
    |> reason(":function_clause")
  end

  test "Task await" do
    :proc_lib.spawn(fn() ->
      Task.async(fn() ->
        Process.sleep(2)
      end)
      |> Task.await(1)
    end)
    |> assert_crash_caught
    |> reason_regex(~r/^{:exit, {:timeout/)
  end


  test "Ranch no function clause matching in :cow_http_hd.token_ci_list_sep/3" do
    pid = self()
    msg = 'Ranch listener ~p had connection process started with ~p:start_link/4 at ~p exit with reason: ~999999p~n'
    stacktrace = [
      {:cow_http_hd, :token_ci_list_sep, ["Te", [], "keep-alive"], [file: '/app/deps/cowlib/src/cow_http_hd.erl', line: 191]},
      {:cow_http_hd, :parse_connection, 1, [file: '/app/deps/cowlib/src/cow_http_hd.erl', line: 31]}
    ]
    :error_logger.error_msg msg, [__MODULE__, :cowboy_protocol, pid, {:function_clause, stacktrace}]
    pid
    |> assert_crash_caught
    |> reason(":function_clause")
  end

  defp reason(reason, expected) do
    assert expected == reason
  end

  defp reason_regex(reason, expected) do
    assert reason =~ expected
  end

end
