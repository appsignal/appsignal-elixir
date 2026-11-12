if Appsignal.Dependencies.present?(:httpoison) and Appsignal.Dependencies.present?(:plug_cowboy) do
  defmodule AppsignalTest.HTTPoisonClientCallbacks do
    @moduledoc false

    # The callbacks both test clients share, so the one with
    # `Appsignal.HTTPoison.Base` can be compared with the one without.
    defmacro __using__(_opts) do
      quote do
        def process_request_headers(headers), do: [{"x-client", "test"} | headers]

        def process_request_body("raise"), do: raise("Body!")
        def process_request_body(body), do: body
      end
    end
  end

  defmodule HTTPoisonClient do
    use Appsignal.HTTPoison.Base
    use AppsignalTest.HTTPoisonClientCallbacks
  end

  defmodule UninstrumentedHTTPoisonClient do
    use HTTPoison.Base
    use AppsignalTest.HTTPoisonClientCallbacks
  end

  defmodule HTTPoisonBaseURLClient do
    use Appsignal.HTTPoison.Base

    def process_request_url(path), do: AppsignalTest.HTTPServer.url(path)
  end

  defmodule Appsignal.HTTPoisonTest do
    use AppsignalTest.IntegrationCase
    alias AppsignalTest.HTTPServer

    setup do
      start_supervised!(HTTPServer)
      :ok
    end

    @clients [
      {Appsignal.HTTPoison, HTTPoison},
      {HTTPoisonClient, UninstrumentedHTTPoisonClient}
    ]

    describe "sending a request, compared with plain HTTPoison" do
      for {client, plain} <- @clients do
        @tag client: client, plain: plain
        test "#{inspect(client)} sends the request as #{inspect(plain)} does", %{
          client: client,
          plain: plain
        } do
          url = HTTPServer.url("/users?page=2")
          headers = [{"content-type", "text/plain"}]

          response = instrumented(fn -> client.post(url, "name=Alice", headers) end)
          plain_response = plain.post(url, "name=Alice", headers)

          assert without_date(response) == without_date(plain_response)
          assert {:ok, %HTTPoison.Response{status_code: 200, body: "OK"}} = response
          assert [request, plain_request] = HTTPServer.requests()
          assert request == plain_request

          assert %{method: "POST", path: "/users?page=2", body: "name=Alice"} = request
          assert %{"content-type" => "text/plain"} = request.headers
        end

        @tag client: client, plain: plain
        test "#{inspect(client)} returns the error for a refused connection as #{inspect(plain)} does",
             %{client: client, plain: plain} do
          url = HTTPServer.refused_url()
          response = instrumented(fn -> client.get(url) end)

          assert response == plain.get(url)
          assert {:error, %HTTPoison.Error{reason: :econnrefused}} = response
        end

        @tag client: client, plain: plain
        test "#{inspect(client)} raises the error for a refused connection as #{inspect(plain)} does",
             %{client: client, plain: plain} do
          url = HTTPServer.refused_url()
          error = assert_raise HTTPoison.Error, fn -> instrumented(fn -> client.get!(url) end) end

          assert error == assert_raise(HTTPoison.Error, fn -> plain.get!(url) end)
        end
      end

      for {function, arity} <- HTTPoison.__info__(:functions),
          verb = function |> Atom.to_string() |> String.trim_trailing("!") |> String.to_atom(),
          verb in [:request, :get, :head, :delete, :options, :post, :put, :patch],
          {verb, arity} != {:request, 1} do
        test "Appsignal.HTTPoison sends #{function}/#{arity} as HTTPoison does" do
          args = request_args(unquote(verb), unquote(arity))

          response =
            instrumented(fn -> apply(Appsignal.HTTPoison, unquote(function), args) end)

          assert without_date(response) ==
                   without_date(apply(HTTPoison, unquote(function), args))

          assert [request, request] = HTTPServer.requests()
        end
      end

      test "Appsignal.HTTPoison streams an asynchronous response as HTTPoison does" do
        url = HTTPServer.url("/users")

        {:ok, %HTTPoison.AsyncResponse{id: id}} =
          instrumented(fn -> Appsignal.HTTPoison.get(url, [], stream_to: self()) end)

        messages = async_messages(id)

        {:ok, %HTTPoison.AsyncResponse{id: plain_id}} =
          HTTPoison.get(url, [], stream_to: self())

        assert messages == async_messages(plain_id)
        assert [%HTTPoison.AsyncStatus{code: 200} | _] = messages
      end

      test "HTTPoisonClient reraises its request callback's error as UninstrumentedHTTPoisonClient does" do
        url = HTTPServer.url()

        error = raised(fn -> instrumented(fn -> HTTPoisonClient.post(url, "raise") end) end)

        assert {:error, %RuntimeError{message: "Body!"}} = error
        assert error == raised(fn -> UninstrumentedHTTPoisonClient.post(url, "raise") end)
        assert HTTPServer.requests() == []
      end
    end

    describe "the span recorded for a request" do
      for {client, _plain} <- @clients do
        @tag client: client
        test "is a child span named after the method and origin, for #{inspect(client)}", %{
          client: client
        } do
          instrumented(fn -> client.get(HTTPServer.url("/users/4?page=2")) end)

          [parent] = root_spans()
          assert [span] = children(spans(), parent)
          assert span["name"] == "GET #{HTTPServer.origin(HTTPServer.url())}"
          assert category(span) == "request.httpoison"
          assert span["error"] == nil
        end

        @tag client: client
        test "leaves the user info out of its name, for #{inspect(client)}", %{client: client} do
          url = String.replace(HTTPServer.url(), "://", "://user:secret@")
          instrumented(fn -> client.get(url) end)

          assert [_span] = named(spans(), "GET #{HTTPServer.origin(HTTPServer.url())}")
        end

        @tag client: client
        test "has no error for an error response, for #{inspect(client)}", %{client: client} do
          assert {:ok, %HTTPoison.Response{status_code: 500}} =
                   instrumented(fn -> client.get(HTTPServer.url("/status/500")) end)

          assert [%{"error" => nil}] =
                   named(spans(), "GET #{HTTPServer.origin(HTTPServer.url())}")
        end

        @tag client: client
        test "has no error for a refused connection, for #{inspect(client)}", %{client: client} do
          url = HTTPServer.refused_url()
          instrumented(fn -> client.get(url) end)

          assert [%{"error" => nil}] = named(spans(), "GET #{HTTPServer.origin(url)}")
        end

        @tag client: client
        test "has no error when a refused connection raises, for #{inspect(client)}", %{
          client: client
        } do
          url = HTTPServer.refused_url()
          assert_raise HTTPoison.Error, fn -> instrumented(fn -> client.get!(url) end) end

          assert [%{"error" => nil}] = named(spans(), "GET #{HTTPServer.origin(url)}")
        end
      end

      test "has no error when the client's request callback raises" do
        raised(fn -> instrumented(fn -> HTTPoisonClient.post(HTTPServer.url(), "raise") end) end)

        assert [%{"error" => nil}] =
                 named(spans(), "POST #{HTTPServer.origin(HTTPServer.url())}")
      end

      # Pins current behaviour, not intended behaviour: the span is named after
      # the URL passed to the client, before `process_request_url/1` turns it
      # into the URL HTTPoison requests. See
      # https://github.com/appsignal/appsignal-elixir/issues/1079.
      test "is named GET when the client's process_request_url/1 builds the URL" do
        assert {:ok, %HTTPoison.Response{status_code: 200}} =
                 instrumented(fn -> HTTPoisonBaseURLClient.get("/users") end)

        assert [%{path: "/users"}] = HTTPServer.requests()
        [parent] = root_spans()
        assert [%{"name" => "GET "}] = children(spans(), parent)
      end

      # Pins current behaviour, not intended behaviour: HTTPoison adds `http://`
      # to a URL without a scheme, after the span is named. See
      # https://github.com/appsignal/appsignal-elixir/issues/1079.
      test "is named after a URL without a scheme as it was passed" do
        "http://" <> url = HTTPServer.url("/users")

        assert {:ok, %HTTPoison.Response{status_code: 200}} =
                 instrumented(fn -> Appsignal.HTTPoison.get(url) end)

        assert [%{path: "/users"}] = HTTPServer.requests()
        [parent] = root_spans()
        assert [%{"name" => "GET localhost:"}] = children(spans(), parent)
      end
    end

    describe "requests that record no span" do
      for {client, _plain} <- @clients do
        @tag client: client
        test "outside an instrumented function, for #{inspect(client)}", %{client: client} do
          assert {:ok, %HTTPoison.Response{status_code: 200}} = client.get(HTTPServer.url())
          assert spans() == []
        end
      end

      # Pins current behaviour, not intended behaviour: `request/1` and
      # `request!/1` are not instrumented yet, so a request made with a request
      # struct records no span. See
      # https://github.com/appsignal/appsignal-elixir/issues/1073.
      test "made with a request struct" do
        request = %HTTPoison.Request{method: :get, url: HTTPServer.url()}

        assert {:ok, %HTTPoison.Response{status_code: 200}} =
                 instrumented(fn -> Appsignal.HTTPoison.request(request) end)

        assert [%{"name" => "parent"}] = spans()
      end
    end

    defp instrumented(fun), do: Appsignal.instrument("parent", fun)

    defp raised(fun) do
      fun.()
      flunk("did not raise")
    rescue
      error -> {:error, error}
    end

    defp without_date({:ok, %HTTPoison.Response{} = response}),
      do: {:ok, without_date(response)}

    defp without_date(%HTTPoison.Response{headers: headers} = response) do
      %{
        response
        | headers: Enum.reject(headers, fn {name, _} -> String.downcase(name) == "date" end)
      }
    end

    # The arguments for a request function, as many as its arity takes.
    defp request_args(verb, arity) do
      url = HTTPServer.url("/users")
      headers = [{"x-test", "1"}]
      options = [params: [page: "2"]]

      args =
        case verb do
          :request -> [:put, url, "name=Alice", headers, options]
          verb when verb in [:post, :put, :patch] -> [url, "name=Alice", headers, options]
          _verb -> [url, headers, options]
        end

      Enum.take(args, arity)
    end

    # The messages of an asynchronous response, without its ID or date.
    defp async_messages(id, messages \\ []) do
      receive do
        %HTTPoison.AsyncEnd{id: ^id} ->
          Enum.reverse([:end | messages])

        %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
          headers = Enum.reject(headers, fn {name, _} -> String.downcase(name) == "date" end)
          async_messages(id, [%HTTPoison.AsyncHeaders{headers: headers} | messages])

        %{id: ^id} = message ->
          async_messages(id, [%{message | id: nil} | messages])
      after
        2_000 -> flunk("Timed out waiting for the asynchronous response")
      end
    end
  end
end
