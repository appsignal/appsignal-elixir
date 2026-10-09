defmodule AppsignalTest.Spans do
  @moduledoc """
  The spans a test created, as the extension reports them, read through
  `Appsignal.Test.Nif`.

  Each span is a map with the extension's keys: `"name"`, `"namespace"`,
  `"attributes"`, `"sample_data"`, `"error"`, `"span_id"`, `"parent_span_id"`,
  `"trace_id"` and `"closed"`. Sample data values are decoded from JSON.
  """

  import ExUnit.Assertions
  alias Appsignal.Test

  @doc """
  Every span created since `Appsignal.Test.Nif` started, in the order they
  were created, from any process.
  """
  def spans do
    references = Enum.reverse(recorded(:span))
    open = Map.new(references, &{&1, &1 |> Appsignal.Nif.span_to_json() |> elem(1)})

    # Read after the open spans: a span another process closes in between can
    # no longer be read, but its data is recorded before it closes.
    closed = Map.new(recorded(:closed_span))

    for reference <- references do
      case Map.fetch(closed, reference) do
        {:ok, json} -> json |> decode() |> Map.put("closed", true)
        :error -> decode(open[reference])
      end
    end
  end

  @doc """
  Waits until `fun` returns a truthy value for the spans created so far, and
  returns the spans. By default, waits until every span is closed.

  Spans created in other processes, such as a LiveView, a channel or a job,
  can still be open when the call that caused them returns.
  """
  def await_spans(fun \\ &all_closed?/1, timeout \\ 2_000) do
    deadline = System.monotonic_time(:millisecond) + timeout
    do_await_spans(fun, deadline)
  end

  defp do_await_spans(fun, deadline) do
    spans = spans()

    cond do
      fun.(spans) ->
        spans

      System.monotonic_time(:millisecond) > deadline ->
        flunk("Timed out waiting for spans. Spans so far:\n\n#{inspect(spans, pretty: true)}")

      true ->
        Process.sleep(10)
        do_await_spans(fun, deadline)
    end
  end

  def all_closed?(spans), do: Enum.all?(spans, & &1["closed"])

  def open_spans(spans \\ spans()), do: Enum.reject(spans, & &1["closed"])

  def root_spans(spans \\ spans()), do: Enum.filter(spans, &(&1["parent_span_id"] == ""))

  def children(spans, %{"span_id" => id}), do: Enum.filter(spans, &(&1["parent_span_id"] == id))

  def category(span), do: span["attributes"]["appsignal:category"]

  def named(spans, name), do: Enum.filter(spans, &(&1["name"] == name))

  defp recorded(key) do
    case Test.Nif.get(key) do
      {:ok, values} -> values
      :error -> []
    end
  end

  defp decode(json) do
    case Jason.decode(json) do
      {:ok, span} ->
        Map.update(span, "sample_data", %{}, fn sample_data ->
          Map.new(sample_data, fn {key, value} -> {key, decode_value(value)} end)
        end)

      {:error, _} ->
        %{}
    end
  end

  # Sample data is sent as JSON, but an empty value is an empty string.
  defp decode_value(value) do
    case Jason.decode(value) do
      {:ok, decoded} -> decoded
      {:error, _} -> value
    end
  end
end
