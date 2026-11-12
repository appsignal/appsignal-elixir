if Appsignal.Dependencies.present?(:absinthe) do
  defmodule AppsignalTest.AbsintheSchema do
    @moduledoc false
    use Absinthe.Schema

    object :user do
      field(:id, :id)
      field(:name, :string)
    end

    query do
      field :user, :user do
        arg(:id, non_null(:id))
        resolve(fn %{id: id}, _resolution -> {:ok, %{id: id, name: "User #{id}"}} end)
      end

      field :failing, :string do
        resolve(fn _args, _resolution -> {:error, "Resolver failed"} end)
      end

      field :raising, :string do
        resolve(fn _args, _resolution -> raise "Resolver raised" end)
      end
    end

    mutation do
      field :create_user, :user do
        arg(:name, non_null(:string))
        resolve(fn %{name: name}, _resolution -> {:ok, %{id: "1", name: name}} end)
      end
    end
  end

  defmodule Appsignal.AbsintheTest do
    use AppsignalTest.IntegrationCase
    import AppsignalTest.Utils, only: [with_config: 2]
    alias Appsignal.Tracer
    alias AppsignalTest.AbsintheSchema

    @get_user "query GetUser { user(id: 1) { name } }"
    @create_user ~s|mutation CreateUser { createUser(name: "Jane") { id name } }|

    describe "running an operation through Absinthe" do
      test "returns the operation's result" do
        assert run(@get_user, operation_name: "GetUser") ==
                 {:ok, %{data: %{"user" => %{"name" => "User 1"}}}}
      end

      test "returns a mutation's result" do
        assert {:ok, %{data: %{"createUser" => %{"id" => "1", "name" => "Jane"}}}} =
                 run(@create_user, operation_name: "CreateUser")
      end

      test "returns a resolver's GraphQL errors" do
        assert {:ok, %{data: %{"failing" => nil}, errors: [%{message: "Resolver failed"}]}} =
                 run("query Failing { failing }", operation_name: "Failing")
      end

      test "returns the error for a document that does not parse" do
        assert {:ok, %{errors: [%{message: "syntax error before: " <> _}]}} = run("{ user(")
      end
    end

    describe "the span recorded for an operation" do
      test "is a root span named after the operation" do
        run(@get_user, operation_name: "GetUser")

        assert [%{"parent_span_id" => ""} = span] = spans()
        assert span["name"] == "GetUser"
        assert span["namespace"] == "graphql"
        assert category(span) == "call.graphql"
        assert span["error"] == nil
      end

      test "is named after a mutation's operation" do
        run(@create_user, operation_name: "CreateUser")

        assert [%{"name" => "CreateUser", "namespace" => "graphql"} = span] = spans()
        assert category(span) == "call.graphql"
      end

      test "is named graphql when the operation name is only in the document" do
        run(@get_user)
        assert [%{"name" => "graphql", "namespace" => "graphql"}] = spans()
      end

      test "is named graphql for an anonymous operation" do
        run("{ user(id: 1) { name } }")
        assert [%{"name" => "graphql", "namespace" => "graphql"}] = spans()
      end

      test "has no error for an operation with GraphQL errors" do
        run("query Failing { failing }", operation_name: "Failing")
        assert [%{"name" => "Failing", "error" => nil}] = spans()
      end

      test "has no error for a document that does not parse" do
        run("{ user(")
        assert [%{"name" => "graphql", "error" => nil}] = spans()
      end

      test "is a child of the current span, which keeps its name and namespace" do
        Appsignal.instrument("parent", fn -> run(@get_user, operation_name: "GetUser") end)

        assert [parent] = root_spans()
        assert parent["name"] == "parent"
        assert parent["namespace"] == "background_job"

        assert [span] = children(spans(), parent)
        assert span["name"] == "GetUser"
        assert category(span) == "call.graphql"
      end

      test "names the current root span after the operation when it has no name" do
        root = Tracer.create_span("http_request")
        run(@get_user, operation_name: "GetUser")
        Tracer.close_span(root)

        assert [parent] = root_spans()
        assert parent["name"] == "GetUser"
        assert parent["namespace"] == "http_request"
        assert [%{"name" => "GetUser"}] = children(spans(), parent)
      end
    end

    # Pins current behaviour, not intended behaviour: a resolver that raises
    # leaves the operation's span open, without the error, as the process's
    # current span. The skipped test below is the intended behaviour. See
    # https://github.com/appsignal/appsignal-elixir/issues/1080.
    describe "a resolver that raises" do
      @tag leaves_spans_open: "Absinthe emits no stop event when a resolver raises"
      test "leaves the operation's span open and current" do
        assert_raise RuntimeError, "Resolver raised", fn ->
          run("query Raising { raising }", operation_name: "Raising")
        end

        assert [%{"name" => "Raising", "closed" => false, "error" => nil} = span] = spans()
        assert Tracer.current_span() != nil

        run(@get_user, operation_name: "GetUser")

        assert [%{"name" => "GetUser", "closed" => true}] = children(spans(), span)
      end

      @tag leaves_spans_open: "Absinthe emits no stop event when a resolver raises"
      test "leaves the operation's span open under the closed span it ran in" do
        assert_raise RuntimeError, fn ->
          Appsignal.instrument("parent", fn -> run("{ raising }") end)
        end

        assert [%{"closed" => true, "error" => nil} = parent] = root_spans()
        assert [%{"name" => "graphql", "closed" => false}] = children(spans(), parent)
      end

      @tag skip: "Absinthe emits no event when a resolver raises; needs a design decision"
      test "closes the operation's span and records the error" do
        assert_raise RuntimeError, fn -> run("{ raising }") end

        assert [%{"closed" => true, "error" => %{"name" => "RuntimeError"}}] = spans()
        assert Tracer.current_span() == nil
      end
    end

    describe "attaching the :telemetry handlers" do
      test "attaches to Absinthe's operation events" do
        for event <- events() do
          assert attached?(Appsignal.Absinthe, event)
        end
      end
    end

    describe "attaching the :telemetry handlers, with instrument_absinthe set to false" do
      @describetag :detaches_handlers

      setup do
        Enum.each(events(), &:telemetry.detach({Appsignal.Absinthe, &1}))
        with_config(%{instrument_absinthe: false}, fn -> Appsignal.start([], []) end)
        :ok
      end

      test "does not attach to Absinthe's operation events" do
        for event <- events() do
          refute attached?(Appsignal.Absinthe, event)
        end
      end

      test "records no span for an operation" do
        assert {:ok, %{data: %{"user" => _}}} = run(@get_user, operation_name: "GetUser")
        assert spans() == []
      end
    end

    defp run(document, options \\ []) do
      Absinthe.run(document, AbsintheSchema, options)
    end

    defp events do
      [[:absinthe, :execute, :operation, :start], [:absinthe, :execute, :operation, :stop]]
    end
  end
end
