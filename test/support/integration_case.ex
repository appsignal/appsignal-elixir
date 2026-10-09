defmodule AppsignalTest.IntegrationCase do
  @moduledoc """
  For tests that drive a real library the way an application does and
  assert on the spans AppSignal records, through `AppsignalTest.Spans`.

  After each test, it fails the test when:

    * a span the test created is still open. Tag a test with
      `leaves_spans_open: "why"` when an open span is the behaviour it pins.
      A tagged test fails when it leaves no span open, so the tag goes once
      that behaviour is fixed.
    * an AppSignal `:telemetry` handler was attached before the test and no
      longer is. `:telemetry` detaches a handler for good when it raises.
      Tag a test that detaches handlers on purpose with `:detaches_handlers`,
      which fails when it detaches none. Either way, the handler is attached
      again afterwards.
    * any `:telemetry` handler raised, as reported by the
      `[:telemetry, :handler, :failure]` event.

  The tests read spans back from the extension, so they do not run in the
  `test_no_nif` environment.
  """

  use ExUnit.CaseTemplate
  alias Appsignal.Test

  @recorders [Test.Nif, Test.Tracer, Test.Span, Test.Monitor]

  using do
    quote do
      import AppsignalTest.Spans
      @moduletag :skip_env_test_no_nif
    end
  end

  setup tags do
    # Started outside the test supervisor, so the checks below can still read
    # them after the test process exits.
    Enum.each(@recorders, &restart_recorder/1)

    handlers = appsignal_handlers()
    {:ok, failures} = Agent.start(fn -> [] end)

    :ok =
      :telemetry.attach(
        {__MODULE__, :handler_failures},
        [:telemetry, :handler, :failure],
        &__MODULE__.record_failure/4,
        failures
      )

    on_exit(fn ->
      :telemetry.detach({__MODULE__, :handler_failures})
      handler_failures = Agent.get(failures, & &1)
      Agent.stop(failures)

      open = open_spans_after()
      detached = handlers -- appsignal_handlers()
      Enum.each(detached, &reattach/1)

      Enum.each(@recorders, &stop_recorder/1)

      check(handler_failures, open, Enum.map(detached, & &1.id), tags)
    end)

    :ok
  end

  @doc false
  def record_failure(_event, _measurements, metadata, failures) do
    Agent.update(failures, &[metadata | &1])
  end

  defp open_spans_after do
    # Spans in other processes can close shortly after the test's last call.
    deadline = System.monotonic_time(:millisecond) + 1_000
    wait_for_open_spans(deadline)
  end

  defp wait_for_open_spans(deadline) do
    case AppsignalTest.Spans.open_spans() do
      [] ->
        []

      open ->
        if System.monotonic_time(:millisecond) > deadline do
          open
        else
          Process.sleep(10)
          wait_for_open_spans(deadline)
        end
    end
  end

  @doc false
  def check(handler_failures, open, detached, tags) do
    problems =
      Enum.reject(
        [
          handler_failures != [] &&
            "A :telemetry handler raised:\n\n#{inspect(handler_failures, pretty: true)}",
          open_problem(open, Map.has_key?(tags, :leaves_spans_open)),
          detached_problem(detached, Map.has_key?(tags, :detaches_handlers))
        ],
        &(&1 in [false, nil])
      )

    case problems do
      [] -> :ok
      _ -> raise ExUnit.AssertionError, message: Enum.join(problems, "\n\n")
    end
  end

  defp open_problem([], true),
    do: "The test is tagged leaves_spans_open, but left no span open. Remove the tag."

  defp open_problem(open, false) when open != [],
    do: "Spans left open:\n\n#{inspect(open, pretty: true)}"

  defp open_problem(_open, _tagged), do: nil

  defp detached_problem([], true),
    do: "The test is tagged detaches_handlers, but detached no handler. Remove the tag."

  defp detached_problem(detached, false) when detached != [],
    do: "AppSignal :telemetry handlers detached:\n\n#{inspect(detached, pretty: true)}"

  defp detached_problem(_detached, _tagged), do: nil

  defp appsignal_handlers do
    for %{id: {module, _event}} = handler <- :telemetry.list_handlers([]),
        is_atom(module),
        String.starts_with?(Atom.to_string(module), "Elixir.Appsignal."),
        do: handler
  end

  # A detached handler stays detached for the rest of the run, which would
  # fail later tests for this test's reason.
  defp reattach(%{id: id, event_name: event, function: function, config: config}) do
    :telemetry.attach(id, event, function, config)
  end

  defp restart_recorder(recorder) do
    stop_recorder(recorder)
    {:ok, _pid} = Agent.start(fn -> %{} end, name: recorder)
  end

  defp stop_recorder(recorder) do
    case Process.whereis(recorder) do
      nil -> :ok
      pid -> Agent.stop(pid)
    end
  end
end
