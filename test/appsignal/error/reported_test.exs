defmodule Appsignal.ReportedTest.ClientError do
  defexception message: "Not found", plug_status: 404
end

defmodule Appsignal.Error.ReportedTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Error.Reported
  alias Appsignal.{Span, Test, Tracer}

  @stacktrace [{__MODULE__, :report, 0, [file: ~c"reported_test.exs", line: 1]}]

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Monitor)
    setup_with_config(%{enable_error_backend: true})
  end

  test "remembers an error reported with a stack trace" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace)

    assert Reported.reported?(self(), @stacktrace)
  end

  test "remembers an exception reported with a stack trace" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, %RuntimeError{message: "Exception!"}, @stacktrace)

    assert Reported.reported?(self(), @stacktrace)
  end

  test "remembers an exception with a status below 500, which it does not report" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, %Appsignal.ReportedTest.ClientError{}, @stacktrace)

    assert Reported.reported?(self(), @stacktrace)
  end

  test "does not match another stack trace or another process" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace)

    refute Reported.reported?(self(), [{__MODULE__, :other, 0, []}])
    refute Reported.reported?(spawn(fn -> :ok end), @stacktrace)
  end

  test "remembers an error for the span's process, not the caller's" do
    pid = spawn(fn -> Process.sleep(:infinity) end)
    on_exit(fn -> Process.exit(pid, :kill) end)
    span = Tracer.create_span("http_request", nil, pid: pid)

    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace)

    assert Reported.reported?(pid, @stacktrace)
    refute Reported.reported?(self(), @stacktrace)
  end

  test "does not remember an error with an empty stack trace" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, [])

    refute Reported.reported?(self(), [])
  end

  test "does not remember an error added with record: false" do
    span = Tracer.create_span("http_request")

    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace, record: false)

    refute Reported.reported?(self(), @stacktrace)
  end

  test "forgets an error once it is older than the deletion delay" do
    span = Tracer.create_span("http_request")
    Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace)

    Process.sleep(Application.fetch_env!(:appsignal, :deletion_delay) + 50)

    refute Reported.reported?(self(), @stacktrace)
    Reported.sweep()
    refute Reported.reported?(self(), @stacktrace)
  end

  test "remembers nothing when the error backend is disabled" do
    with_config(%{enable_error_backend: false}, fn ->
      span = Tracer.create_span("http_request")

      Span.add_error(span, :error, %RuntimeError{message: "Exception!"}, @stacktrace)

      refute Reported.reported?(self(), @stacktrace)
    end)
  end
end
