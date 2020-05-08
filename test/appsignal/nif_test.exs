defmodule Appsignal.NifTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils, only: [is_reference_or_binary: 1]

  test "whether the agent starts" do
    assert :ok = Appsignal.Nif.start()
  end

  test "whether the agent stops" do
    assert :ok = Appsignal.Nif.stop()
  end

  @tag :skip_env_test_no_nif
  test "starting transaction returns a reference to the transaction resource" do
    assert {:ok, reference} = Appsignal.Nif.start_transaction("transaction id", "http_request")
    assert is_reference_or_binary(reference)
  end

  if not (Mix.env() in [:test_no_nif]) do
    test "the nif is loaded" do
      assert true == Appsignal.Nif.loaded?()
    end
  end

  if Mix.env() in [:test_no_nif] do
    test "the nif is not loaded" do
      assert false == Appsignal.Nif.loaded?()
    end
  end

  describe "create_root_span/1" do
    test "returns an ok-tuple with a reference to the span" do
      assert {:ok, ref} = Nif.create_root_span("http_request")
      assert is_reference(ref)
    end
  end

  describe "create_root_span_with_timestamp/2" do
    setup do
      {:ok, ref} = Nif.create_root_span_with_timestamp("http_request", 1_588_930_137, 508_176_000)

      %{ref: ref}
    end

    test "returns a reference to the span", %{ref: ref} do
      assert is_reference(ref)
    end

    test "sets the span's start time to the passed value", %{ref: ref} do
      {:ok, json} = Nif.span_to_json(ref)

      assert {:ok, %{"start_time" => 1_588_930_137}} = Jason.decode(json)
    end
  end

  describe "create_child_span/3" do
    test "returns an ok-tuple with a reference to the span" do
      assert {:ok, ref} = Nif.create_child_span("trace_id", "span_id")
      assert is_reference(ref)
    end
  end

  describe "create_child_span_with_timestamp/2" do
    setup do
      {:ok, ref} =
        Nif.create_child_span_with_timestamp(
          "trace_id",
          "span_id",
          1_588_930_137,
          508_176_000
        )

      %{ref: ref}
    end

    test "returns a reference to the span", %{ref: ref} do
      assert is_reference(ref)
    end

    test "sets the span's start time to the passed value", %{ref: ref} do
      {:ok, json} = Nif.span_to_json(ref)

      assert {:ok, %{"start_time" => 1_588_930_137}} = Jason.decode(json)
    end
  end

  describe "agent_version" do
    @tag :skip_env_test_no_nif
    test "returns the installed agent version" do
      assert Appsignal.Nif.agent_version() == Appsignal.Agent.version()
    end

    @tag :skip_env_test
    test "does not return the agent version if the agent is not installed" do
      assert Appsignal.Nif.agent_version() == nil
    end
  end
end
