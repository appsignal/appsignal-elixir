defmodule AppsignalTest.IntegrationCase do
  @moduledoc """
  For tests that drive a real library the way an application does and
  assert on the spans AppSignal records, through `AppsignalTest.Spans`.

  After each test, it fails the test when:

    * a span the test created was left open: it is still open, or AppSignal's
      monitor had to end it once the process holding it exited. Tag a test with
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
    * a child span closed with neither a name nor a category, which AppSignal
      names `[unnamed span]`. Tag a test with `leaves_unnamed_spans: "why"`
      when that is the behaviour it pins. A tagged test fails when it leaves none.
    * a root span closed with an error but no name, which AppSignal names
      `[unnamed action]`. Tag a test with `leaves_unnamed_actions: "why"` when
      that is the behaviour it pins. A tagged test fails when it leaves none.

  The tests read spans back from the extension, so they do not run in the
  `test_no_nif` environment.
  """

  use ExUnit.CaseTemplate
  alias Appsignal.Test

  @recorders [Test.Nif, Test.Tracer, Test.Span, Test.Monitor]

  using do
    quote do
      import AppsignalTest.Spans
      import AppsignalTest.IntegrationCase, only: [attached?: 2]
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

      open = spans_left_open()
      unnamed = named("[unnamed span]") -- open
      unnamed_actions = named("[unnamed action]") -- open
      detached = handlers -- appsignal_handlers()
      Enum.each(detached, &reattach/1)

      Enum.each(@recorders, &stop_recorder/1)

      check(handler_failures, open, Enum.map(detached, & &1.id), tags, unnamed, unnamed_actions)
    end)

    :ok
  end

  @doc "Whether `module` has a `:telemetry` handler attached to `event`."
  def attached?(module, event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(&(&1.id == {module, event}))
  end

  @doc false
  def record_failure(_event, _measurements, metadata, failures) do
    Agent.update(failures, &[metadata | &1])
  end

  defp spans_left_open do
    # Spans in other processes can close shortly after the test's last call.
    deadline = System.monotonic_time(:millisecond) + 1_000
    wait_for_open_spans(deadline)
    Enum.filter(AppsignalTest.Spans.spans(), &AppsignalTest.Spans.left_open?/1)
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
  def check(handler_failures, open, detached, tags, unnamed \\ [], unnamed_actions \\ []) do
    problems =
      Enum.reject(
        [
          handler_failures != [] &&
            "A :telemetry handler raised:\n\n#{inspect(handler_failures, pretty: true)}",
          open_problem(open, Map.has_key?(tags, :leaves_spans_open)),
          detached_problem(detached, Map.has_key?(tags, :detaches_handlers)),
          unnamed_problem(unnamed, Map.has_key?(tags, :leaves_unnamed_spans)),
          unnamed_actions_problem(unnamed_actions, Map.has_key?(tags, :leaves_unnamed_actions))
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

  defp unnamed_problem([], true),
    do: "The test is tagged leaves_unnamed_spans, but left no unnamed span. Remove the tag."

  defp unnamed_problem(unnamed, false) when unnamed != [],
    do: "Spans without a name or category:\n\n#{inspect(unnamed, pretty: true)}"

  defp unnamed_problem(_unnamed, _tagged), do: nil

  defp unnamed_actions_problem([], true),
    do: "The test is tagged leaves_unnamed_actions, but left no unnamed action. Remove the tag."

  defp unnamed_actions_problem(unnamed, false) when unnamed != [],
    do: "Root spans with an error and no name:\n\n#{inspect(unnamed, pretty: true)}"

  defp unnamed_actions_problem(_unnamed, _tagged), do: nil

  defp named(name), do: AppsignalTest.Spans.named(AppsignalTest.Spans.spans(), name)

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
    _ = :telemetry.attach(id, event, function, config)
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
