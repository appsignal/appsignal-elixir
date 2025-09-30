defmodule Appsignal.Logger.BackendTest do
  use ExUnit.Case

  setup do
    start_supervised!(Appsignal.Test.Nif)
    :ok
  end

  test "handle_event/2 sends logs to the extension" do
    Appsignal.Logger.Backend.handle_event(
      {
        :info,
        self(),
        {
          Logger,
          ~c"foo bar baz",
          {{2023, 2, 23}, {14, 25, 56, 241}},
          [
            erl_level: :info,
            application: :phoenix,
            domain: [:elixir],
            file: "lib/phoenix/logger.ex",
            function: "phoenix_endpoint_start/4",
            gl: self(),
            line: 211,
            mfa: {Phoenix.Logger, :phoenix_endpoint_start, 4},
            module: Phoenix.Logger,
            pid: self(),
            request_id: "F0Z3jGx7KNZWD9gAAAFD",
            time: 1_677_159_356_241_326
          ]
        }
      },
      group: "phoenix"
    )

    assert [{"phoenix", 3, 3, "foo bar baz", _}] = Appsignal.Test.Nif.get!(:log)
  end

  test "handle_event/2 sends logfmt logs to the extension" do
    Appsignal.Logger.Backend.handle_event(
      {
        :info,
        self(),
        {
          Logger,
          ~c"foo bar baz",
          {{2023, 2, 23}, {14, 25, 56, 241}},
          [
            erl_level: :info,
            application: :phoenix,
            domain: [:elixir],
            file: "lib/phoenix/logger.ex",
            function: "phoenix_endpoint_start/4",
            gl: self(),
            line: 211,
            mfa: {Phoenix.Logger, :phoenix_endpoint_start, 4},
            module: Phoenix.Logger,
            pid: self(),
            request_id: "F0Z3jGx7KNZWD9gAAAFD",
            time: 1_677_159_356_241_326
          ]
        }
      },
      group: "phoenix",
      format: :logfmt
    )

    assert [{"phoenix", 3, 1, "foo bar baz", _}] = Appsignal.Test.Nif.get!(:log)
  end
end
