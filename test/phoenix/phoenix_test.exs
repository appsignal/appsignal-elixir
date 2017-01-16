defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  import Mock

  alias Appsignal.{Transaction, TransactionRegistry}

  test_with_mock "send_error with metadata and conn", Appsignal.Transaction, [:passthrough], [] do
    conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}}
    stack = System.stacktrace()
    Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack, %{foo: "bar"}, conn)

    t = %Transaction{} = TransactionRegistry.lookup(self())

    assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
    assert called Transaction.set_meta_data(t, :foo, "bar")
    assert called Transaction.set_request_metadata(t, conn)
    assert called Transaction.finish(t)
    assert called Transaction.complete(t)
  end


  @headers [{"content-type", "text/plain"}, {"x-some-value", "1234"}]

  test_with_mock "all request headers are sent", Appsignal.Transaction, [:passthrough], [] do
    conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}, req_headers: @headers}
    Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", [], %{}, conn)

    t = %Transaction{} = TransactionRegistry.lookup(self())

    env = %{:host => "www.example.com", :method => "GET", :peer => "127.0.0.1:12345",
            :port => 0, :query_string => "", :request_path => "",
            :request_uri => "http://www.example.com:0", :script_name => [],
            "req_header.content-type" => "text/plain",
            "req_header.x-some-value" => "1234"}

    assert called Transaction.set_sample_data(t, "environment", env)
  end

end
