defmodule Mix.Tasks.Appsignal.Diagnose.ReportTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.FakeTransmitter

  defp send do
    Appsignal.Diagnose.Report.send(
      Application.get_env(:appsignal, :config, %{}),
      %{}
    )
  end

  setup do
    start_supervised!(FakeTransmitter)

    setup_with_config(%{
      api_key: "foo",
      name: "AppSignal test suite app",
      env: "prod",
      diagnose_endpoint: "http://localhost:4005/diag"
    })

    :ok
  end

  describe "with valid response" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 200, body: ~s({"token": "support token"})}})
    end

    test "sends the diagnostics report to AppSignal and returns support token" do
      assert send() == {:ok, "support token"}

      assert [{"http://localhost:4005/diag", {%{diagnose: %{}}, :json}, _config}] =
               FakeTransmitter.transmitted()
    end
  end

  describe "with invalid response" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 200, body: ~s({"foo": bar})}})
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert send() == {:error, %{body: ~s({"foo": bar}), status_code: 200}}
    end
  end

  describe "with error response" do
    setup do
      FakeTransmitter.set_response({:ok, %{status: 500, body: ~s(woops)}})
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert send() == {:error, %{status_code: 500, body: "woops"}}
    end
  end

  describe "with no server response" do
    setup do
      FakeTransmitter.set_response({:error, %Mint.TransportError{reason: :econnrefused}})
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert {:error, %{reason: _}} = send()
    end
  end
end
