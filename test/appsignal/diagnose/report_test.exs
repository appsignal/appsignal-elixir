defmodule Mix.Tasks.Appsignal.Diagnose.ReportTest do
  use ExUnit.Case
  import AppsignalTest.Utils

  defp send do
    Appsignal.Diagnose.Report.send(
      Application.get_env(:appsignal, :config, %{}),
      %{}
    )
  end

  setup do
    diagnose_bypass = Bypass.open()

    setup_with_config(%{
      api_key: "foo",
      name: "AppSignal test suite app",
      env: "prod",
      diagnose_endpoint: "http://localhost:#{diagnose_bypass.port}/diag"
    })

    {:ok, diagnose_bypass: diagnose_bypass}
  end

  describe "with valid response" do
    setup %{diagnose_bypass: diagnose_bypass} do
      Bypass.expect(diagnose_bypass, fn conn ->
        assert "/diag" == conn.request_path
        assert "POST" == conn.method
        Plug.Conn.resp(conn, 200, ~s({"token": "support token"}))
      end)

      :ok
    end

    test "sends the diagnostics report to AppSignal and returns support token" do
      assert send() == {:ok, "support token"}
    end
  end

  describe "with invalid response" do
    setup %{diagnose_bypass: diagnose_bypass} do
      Bypass.expect(diagnose_bypass, fn conn ->
        assert "/diag" == conn.request_path
        assert "POST" == conn.method
        Plug.Conn.resp(conn, 200, ~s({"foo": bar}))
      end)

      :ok
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert send() == {:error, %{body: ~s({"foo": bar}), status_code: 200}}
    end
  end

  describe "with error response" do
    setup %{diagnose_bypass: diagnose_bypass} do
      Bypass.expect(diagnose_bypass, fn conn ->
        assert "/diag" == conn.request_path
        assert "POST" == conn.method
        Plug.Conn.resp(conn, 500, ~s(woops))
      end)

      :ok
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert send() == {:error, %{status_code: 500, body: "woops"}}
    end
  end

  describe "with no server response" do
    setup %{diagnose_bypass: diagnose_bypass} do
      Bypass.down(diagnose_bypass)
      :ok
    end

    test "sends the diagnostics report to AppSignal and returns an error" do
      assert {:error, %{reason: _}} = send()
    end
  end
end
