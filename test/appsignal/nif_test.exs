unless Code.ensure_loaded?(Appsignal.Agent) do
  {_, _} = Code.eval_file("agent.exs")
end

defmodule Appsignal.NifTest do
  alias Appsignal.Nif
  use ExUnit.Case, async: true

  test "whether the agent starts" do
    assert :ok = Nif.start()
  end

  test "whether the agent stops" do
    assert :ok = Nif.stop()
  end

  if Mix.env() not in [:test_no_nif] do
    test "the nif is loaded" do
      assert true == Nif.loaded?()
    end
  end

  if Mix.env() in [:test_no_nif] do
    test "the nif is not loaded" do
      assert false == Nif.loaded?()
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

    @tag :skip_env_test_no_nif
    test "sets the span's start time to the passed value", %{ref: ref} do
      {:ok, json} = Nif.span_to_json(ref)

      assert {:ok,
              %{"start_time_seconds" => 1_588_930_137, "start_time_nanoseconds" => 508_176_000}} =
               Jason.decode(json)
    end
  end

  describe "create_child_span/3" do
    test "returns an ok-tuple with a reference to the span" do
      {:ok, parent} = Nif.create_root_span("http_request")

      assert {:ok, ref} = Nif.create_child_span(parent)
      assert is_reference(ref)
    end
  end

  describe "create_child_span_with_timestamp/2" do
    setup do
      {:ok, parent} = Nif.create_root_span("http_request")

      {:ok, ref} = Nif.create_child_span_with_timestamp(parent, 1_588_930_137, 508_176_000)

      %{ref: ref}
    end

    test "returns a reference to the span", %{ref: ref} do
      assert is_reference(ref)
    end

    @tag :skip_env_test_no_nif
    test "sets the span's start time to the passed value", %{ref: ref} do
      {:ok, json} = Nif.span_to_json(ref)

      assert {:ok,
              %{"start_time_seconds" => 1_588_930_137, "start_time_nanoseconds" => 508_176_000}} =
               Jason.decode(json)
    end
  end

  describe "close_span/1" do
    test "returns :ok" do
      {:ok, ref} = Nif.create_root_span("http_request")
      assert Nif.close_span(ref) == :ok
    end
  end
end
