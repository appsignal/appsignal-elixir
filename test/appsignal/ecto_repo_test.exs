defmodule Appsignal.TestEctoRepo do
  use Appsignal.Ecto.Repo,
    otp_app: :plug_example,
    adapter: Ecto.Adapters.Postgres
end

defmodule Appsignal.TestEctoRepoWithOverride do
  use Appsignal.Ecto.Repo

  def default_options(operation) do
    super(operation) ++
      [
        foo: "bar"
      ]
  end
end

defmodule Appsignal.EctoRepoTest do
  use ExUnit.Case
  alias Appsignal.Test

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Monitor)

    :ok
  end

  test "use Appsignal.Ecto.Repo passes through options to Ecto.Repo" do
    assert Appsignal.TestEctoRepo.get_received_opts() == [
             otp_app: :plug_example,
             adapter: Ecto.Adapters.Postgres
           ]
  end

  test "use Appsignal.Ecto.Repo can have overriden default options" do
    assert Appsignal.TestEctoRepoWithOverride.default_options(:all) == [
             telemetry_options: [
               _appsignal_current_span: nil
             ],
             foo: "bar"
           ]
  end

  describe "use Appsignal.Ecto.Repo, with a root span" do
    setup do
      %{span: Appsignal.Tracer.create_span("http_request")}
    end

    test "it returns the current span in telemetry options", %{span: span} do
      assert Appsignal.TestEctoRepo.default_options(:all) == [
               telemetry_options: [
                 _appsignal_current_span: span
               ]
             ]
    end
  end

  describe "use Appsignal.Ecto.Repo, without a root span" do
    test "it returns nil as the current span in telemetry options" do
      assert Appsignal.TestEctoRepo.default_options(:all) == [
               telemetry_options: [
                 _appsignal_current_span: nil
               ]
             ]
    end
  end

  describe "default_options/1, with a root span" do
    setup do
      %{span: Appsignal.Tracer.create_span("http_request")}
    end

    test "it returns the current span in telemetry options", %{span: span} do
      assert Appsignal.Ecto.Repo.default_options(:all) == [
               telemetry_options: [
                 _appsignal_current_span: span
               ]
             ]
    end
  end

  describe "default_options/1, without a root span" do
    test "it returns nil as the current span in telemetry options" do
      assert Appsignal.Ecto.Repo.default_options(:all) == [
               telemetry_options: [
                 _appsignal_current_span: nil
               ]
             ]
    end
  end
end
