defmodule Test400Error do
  defexception message: "400!", plug_status: 400
end

defmodule Test500Error do
  defexception message: "500!", plug_status: 500
end

defmodule AppsignalSpanTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}
  import AppsignalTest.Utils, only: [with_config: 2]

  setup do
    start_supervised(Test.Nif)
    :ok
  end

  describe ".create_root/2" do
    setup :create_root_span

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"http_request"}] = Test.Nif.get!(:create_root_span)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span} do
      assert span.pid == self()
    end
  end

  describe ".create_root/2, when passing a pid" do
    setup :create_root_span_in_other_process

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"http_request"}] = Test.Nif.get!(:create_root_span)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span, pid: pid} do
      assert span.pid == pid
    end
  end

  describe ".create_root/2 when disabled" do
    setup [:disable_appsignal, :create_root_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not create a root span through the Nif" do
      assert :error = Test.Nif.get(:create_root_span)
    end
  end

  describe ".create_root/3, when passing a start_time" do
    setup do
      [span: Span.create_root("http_request", self(), 1_588_937_136_283_541_000)]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a root span through the Nif" do
      assert [{"http_request", 1_588_937_136, 283_541_000}] =
               Test.Nif.get!(:create_root_span_with_timestamp)
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    @tag :skip_env_test_no_nif
    test "sets the start time through the Nif", %{span: span} do
      assert %{"start_time_seconds" => 1_588_937_136, "start_time_nanoseconds" => 283_541_000} =
               Span.to_map(span)
    end
  end

  describe ".create_child/3" do
    setup [:create_root_span, :create_child_span]

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a child span through the Nif", %{parent: %Span{reference: parent}} do
      assert Test.Nif.get!(:create_child_span) == [{parent}]
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span} do
      assert span.pid == self()
    end
  end

  describe ".create_child/3, when passing a pid" do
    setup [:create_root_span, :create_child_span_in_other_process]

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "creates a child span through the Nif", %{parent: %Span{reference: parent}} do
      assert Test.Nif.get!(:create_child_span) == [{parent}]
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "sets the span's pid", %{span: span, pid: pid} do
      assert span.pid == pid
    end
  end

  describe ".create_child/3 when disabled" do
    setup [:create_root_span, :disable_appsignal, :create_child_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not create a root span through the Nif" do
      assert :error = Test.Nif.get(:create_child_span)
    end
  end

  describe ".create_child/4, when passing a start_time" do
    setup [:create_root_span]

    setup %{span: span} do
      [span: Span.create_child(span, self(), 1_588_937_136_283_541_000)]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    @tag :skip_env_test_no_nif
    test "sets the start time through the Nif", %{span: span} do
      assert %{"start_time_seconds" => 1_588_937_136, "start_time_nanoseconds" => 283_541_000} =
               Span.to_map(span)
    end
  end

  describe ".set_name/2" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_name(span, "test")]
    end

    test "returns a span with the name set", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the name through the Nif", %{span: span} do
      assert %{"name" => "test"} = Span.to_map(span)
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_name(nil, "test") == nil
    end
  end

  describe ".set_name/2, with a span that doesn't have a reference" do
    setup do
      span = %Span{}
      [return: Span.set_name(span, "test"), span: span]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "does not set the name through the Nif" do
      assert Test.Nif.get(:set_span_name) == :error
    end
  end

  describe ".set_name_if_nil/2, with span that doesn't have a name yet" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_name_if_nil(span, "original name")]
    end

    test "when no name is set it returns a span with the name set", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the name through the Nif", %{return: return} do
      assert %{"name" => "original name"} = Span.to_map(return)
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_name(nil, "test") == nil
    end
  end

  describe ".set_name_if_nil/2, with span that does have a name already" do
    setup :create_root_span

    setup %{span: span} do
      span = Span.set_name_if_nil(span, "original name")
      [return: Span.set_name_if_nil(span, "updated name")]
    end

    test "whereturns a span with the name set", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "doesn't update the name through the Nif", %{return: return} do
      assert %{"name" => "original name"} = Span.to_map(return)
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_name(nil, "test") == nil
    end
  end

  describe ".set_namespace/2" do
    setup :create_root_span

    setup %{span: span} do
      %{return: Span.set_namespace(span, "test")}
    end

    test "returns the span", %{return: return, span: span} do
      assert return == span
    end

    test "sets the namespace as an attribute through the Nif", %{
      span: %Span{reference: reference}
    } do
      assert [{^reference, "appsignal.namespace", "test"}] =
               Test.Nif.get!(:set_span_attribute_string)
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_namespace(nil, "test") == nil
    end
  end

  describe ".set_namespace/2, when passing a non-string namespace" do
    setup :create_root_span

    setup %{span: span} do
      %{return: Span.set_namespace(span, :non_string)}
    end

    test "returns the span", %{return: return, span: span} do
      assert return == span
    end

    test "does not set the namespace" do
      assert :error = Test.Nif.get(:set_span_attribute_string)
    end
  end

  describe ".set_namespace_if_nil/2" do
    setup :create_root_span

    setup %{span: span} do
      %{return: Span.set_namespace_if_nil(span, "test")}
    end

    test "returns the span", %{return: return, span: span} do
      assert return == span
    end

    test "sets the namespace as an attribute through the Nif", %{
      span: %Span{reference: reference}
    } do
      assert [{^reference, "appsignal.namespace_if_nil", "test"}] =
               Test.Nif.get!(:set_span_attribute_string)
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_namespace_if_nil(nil, "test") == nil
    end
  end

  describe ".set_namespace_if_nil/2, when passing a non-string namespace" do
    setup :create_root_span

    setup %{span: span} do
      %{return: Span.set_namespace_if_nil(span, :non_string)}
    end

    test "returns the span", %{return: return, span: span} do
      assert return == span
    end

    test "does not set the namespace" do
      assert :error = Test.Nif.get(:set_span_attribute_string)
    end
  end

  describe ".add_error/3" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          raise "Exception!"
        rescue
          exception -> Span.add_error(span, exception, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "sets the error through the Nif", %{span: %Span{reference: reference}} do
      assert [{^reference, "RuntimeError", "** (RuntimeError) Exception!", _}] =
               Test.Nif.get!(:add_span_error)
    end
  end

  describe ".add_error/3, with a badarg" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          _ = String.to_integer("one")
        rescue
          exception -> Span.add_error(span, exception, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "sets the error through the Nif", %{span: %Span{reference: reference}} do
      assert [{^reference, "ArgumentError", _message, _}] = Test.Nif.get!(:add_span_error)
    end
  end

  describe ".add_error/3, with a 500 plug_status" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          raise Test500Error
        rescue
          exception -> Span.add_error(span, exception, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "sets the error through the Nif", %{span: %Span{reference: reference}} do
      assert [{^reference, "Test500Error", _message, _}] = Test.Nif.get!(:add_span_error)
    end
  end

  describe ".add_error/3, with a non-500 plug_status" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          raise Test400Error
        rescue
          exception -> Span.add_error(span, exception, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "does not set the error through the Nif" do
      assert Test.Nif.get(:add_span_error) == :error
    end
  end

  describe ".add_error/3, with a nil span" do
    setup do
      return =
        try do
          raise "Exception!"
        rescue
          exception -> Span.add_error(nil, exception, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns nil", %{return: return} do
      assert return == nil
    end

    test "does not set the error through the Nif" do
      assert Test.Nif.get(:add_span_error) == :error
    end
  end

  describe ".add_error/4" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          raise "Exception!"
        catch
          kind, reason -> Span.add_error(span, kind, reason, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "sets the error through the Nif", %{span: %Span{reference: reference}} do
      assert [{^reference, "RuntimeError", "** (RuntimeError) Exception!", _}] =
               Test.Nif.get!(:add_span_error)
    end
  end

  describe ".add_error/4, with a badarg" do
    setup :create_root_span

    setup %{span: span} do
      return =
        try do
          _ = String.to_integer("one")
        catch
          kind, reason -> Span.add_error(span, kind, reason, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "sets the error through the Nif", %{span: %Span{reference: reference}} do
      assert [{^reference, "ArgumentError", _message, _}] = Test.Nif.get!(:add_span_error)
    end
  end

  describe ".add_error/4, with a nil span" do
    setup do
      return =
        try do
          raise "Exception!"
        catch
          kind, reason -> Span.add_error(nil, kind, reason, __STACKTRACE__)
        end

      [return: return]
    end

    test "returns nil", %{return: return} do
      assert return == nil
    end

    test "does not set the error through the Nif" do
      assert Test.Nif.get(:add_span_error) == :error
    end
  end

  describe ".set_sample_data/3" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data(span, "key", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, when sample data has already been set" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data(span, "key", %{foo: "bar"})
      [return: Span.set_sample_data(span, "key", %{baz: "quux"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "overrides the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"baz\":\"quux\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, setting params" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data(span, "params", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"params" => ~s({"foo":"bar"})}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, setting session_data" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data(span, "session_data", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"session_data" => ~s({"foo":"bar"})}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, if send_params is set to false" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_params: false}, fn ->
        Span.set_sample_data(span, "key", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, if send_params is set to false, when using 'params' as the key" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_params: false}, fn ->
        Span.set_sample_data(span, "params", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "does not set the sample data", %{span: span} do
      assert Span.to_map(span)["sample_data"] == %{}
    end
  end

  describe ".set_sample_data/3, if send_session_data is set to false" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_session_data: false}, fn ->
        Span.set_sample_data(span, "key", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, if send_session_data is set to false, when using 'session_data' as the key" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_session_data: false}, fn ->
        Span.set_sample_data(span, "session_data", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "does not set the sample data", %{span: span} do
      assert Span.to_map(span)["sample_data"] == %{}
    end
  end

  describe ".set_sample_data/3, with a list" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data(span, "custom_data", ["abc", "def"])

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the list as sample data", %{span: span} do
      assert %{"sample_data" => %{"custom_data" => "[\"abc\",\"def\"]"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, with a keyword list" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data(span, "custom_data", abc: "def")

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the keyword list as sample data", %{span: span} do
      assert %{"sample_data" => %{"custom_data" => "[[\"abc\",\"def\"]]"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data/3, when passing invalid data" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_sample_data(span, "key", "non-map value") == span
    end
  end

  describe ".set_sample_data/3, when passing a nil-span" do
    test "returns nil" do
      assert Span.set_sample_data(nil, "key", %{param: "value"}) == nil
    end
  end

  describe ".set_sample_data_if_nil/3" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data_if_nil(span, "key", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, when sample data has already been set" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data_if_nil(span, "key", %{foo: "bar"})
      [return: Span.set_sample_data_if_nil(span, "key", %{baz: "quux"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "does not override the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, setting params" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data_if_nil(span, "params", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"params" => ~s({"foo":"bar"})}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, setting session_data" do
    setup :create_root_span

    setup %{span: span} do
      [return: Span.set_sample_data_if_nil(span, "session_data", %{foo: "bar"})]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"session_data" => ~s({"foo":"bar"})}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, if send_params is set to false" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_params: false}, fn ->
        Span.set_sample_data_if_nil(span, "key", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, if send_params is set to false, when using 'params' as the key" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_params: false}, fn ->
        Span.set_sample_data_if_nil(span, "params", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "does not set the sample data", %{span: span} do
      assert Span.to_map(span)["sample_data"] == %{}
    end
  end

  describe ".set_sample_data_if_nil/3, if send_session_data is set to false" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_session_data: false}, fn ->
        Span.set_sample_data_if_nil(span, "key", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the sample data", %{span: span} do
      assert %{"sample_data" => %{"key" => "{\"foo\":\"bar\"}"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, if send_session_data is set to false, when using 'session_data' as the key" do
    setup :create_root_span

    setup %{span: span} do
      with_config(%{send_session_data: false}, fn ->
        Span.set_sample_data_if_nil(span, "session_data", %{foo: "bar"})
      end)

      :ok
    end

    @tag :skip_env_test_no_nif
    test "does not set the sample data", %{span: span} do
      assert Span.to_map(span)["sample_data"] == %{}
    end
  end

  describe ".set_sample_data_if_nil/3, with a list" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data_if_nil(span, "custom_data", ["abc", "def"])

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the list as sample data", %{span: span} do
      assert %{"sample_data" => %{"custom_data" => "[\"abc\",\"def\"]"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, with a keyword list" do
    setup :create_root_span

    setup %{span: span} do
      Span.set_sample_data_if_nil(span, "custom_data", abc: "def")

      :ok
    end

    @tag :skip_env_test_no_nif
    test "sets the keyword list as sample data", %{span: span} do
      assert %{"sample_data" => %{"custom_data" => "[[\"abc\",\"def\"]]"}} = Span.to_map(span)
    end
  end

  describe ".set_sample_data_if_nil/3, when passing invalid data" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_sample_data_if_nil(span, "key", "non-map value") == span
    end
  end

  describe ".set_sample_data_if_nil/3, when passing a nil-span" do
    test "returns nil" do
      assert Span.set_sample_data_if_nil(nil, "key", %{param: "value"}) == nil
    end
  end

  describe ".set_attribute/2" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_attribute(span, "key", "value") == span
    end

    test "returns span when sending nil values", %{span: span} do
      assert Span.set_attribute(span, "key", nil) == span
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_attribute(nil, "key", "value") == nil
    end
  end

  describe ".set_sql/2" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.set_sql(span, "SELECT * FROM users") == span
    end

    test "returns span when sending nil values", %{span: span} do
      assert Span.set_sql(span, nil) == span
    end

    test "returns nil when passing a nil-span" do
      assert Span.set_sql(nil, "SELECT * FROM users") == nil
    end
  end

  describe ".close/1, when passing a nil" do
    test "returns nil" do
      assert Span.close(nil) == nil
    end
  end

  describe ".close/1, when passing a span" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.close(span) == span
    end

    test ".closes the span through the Nif", %{span: %Span{reference: reference} = span} do
      Span.close(span)
      assert [{^reference}] = Test.Nif.get!(:close_span)
    end
  end

  describe ".close/2, when passing a nil" do
    test "returns nil" do
      assert Span.close(nil, :os.system_time()) == nil
    end
  end

  describe ".close/2, when passing an end time" do
    setup :create_root_span

    test "returns the span", %{span: span} do
      assert Span.close(span, :os.system_time()) == span
    end

    test ".closes the span through the Nif", %{span: %Span{reference: reference} = span} do
      time = :os.system_time()
      Span.close(span, time)
      assert [{^reference, _sec, _nsec}] = Test.Nif.get!(:close_span_with_timestamp)
    end
  end

  @tag :skip_env_test_no_nif
  describe ".to_map/1" do
    setup :create_root_span

    test "returns a map with span metadata", %{span: span} do
      assert %{
               "name" => "",
               "namespace" => "http_request",
               "closed" => false
             } = Span.to_map(span)
    end
  end

  defp create_root_span(_context) do
    [span: Span.create_root("http_request", self())]
  end

  defp create_child_span(%{span: span}) do
    [span: Span.create_child(span, self()), parent: span]
  end

  defp create_root_span_in_other_process(_context) do
    pid = Process.whereis(Test.Nif)
    [span: Span.create_root("http_request", pid), pid: pid]
  end

  defp create_child_span_in_other_process(%{span: span}) do
    pid = Process.whereis(Test.Nif)
    [span: Span.create_child(span, pid), pid: pid, parent: span]
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end
end
