defmodule Appsignal.FakeTeslaBuilder do
  # A mock of a module that uses `Tesla.Builder` (`use Tesla`),
  # implementing `__middleware__`.
  def __middleware__ do
    [
      {Appsignal.FakeTeslaBuilderMiddleware, :call}
    ]
  end
end

defmodule Appsignal.TeslaTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test}
  import AppsignalTest.Utils, only: [with_config: 2]

  test "attaches to Tesla events automatically" do
    assert attached?([:tesla, :request, :start])
    assert attached?([:tesla, :request, :stop])
    assert attached?([:tesla, :request, :exception])
  end

  test "does not attach to Tesla events when :instrument_tesla is set to false" do
    :telemetry.detach({Appsignal.Tesla, [:tesla, :request, :start]})
    :telemetry.detach({Appsignal.Tesla, [:tesla, :request, :stop]})
    :telemetry.detach({Appsignal.Tesla, [:tesla, :request, :exception]})

    with_config(%{instrument_tesla: false}, fn -> Appsignal.start([], []) end)

    assert !attached?([:tesla, :request, :start])
    assert !attached?([:tesla, :request, :stop])
    assert !attached?([:tesla, :request, :exception])

    [:ok, :ok, :ok] = Appsignal.Tesla.attach()
  end

  describe "path_params?/1" do
    test "is false when the Telemetry middleware is absent" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.PathParams, nil}
             ])
    end

    test "is false when the PathParams middleware is absent" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.Telemetry, nil}
             ])
    end

    test "is false when the PathParams middleware appears before the Telemetry middleware" do
      refute Appsignal.Tesla.path_params?([
               {Tesla.Middleware.PathParams, nil},
               {Tesla.Middleware.Telemetry, nil}
             ])
    end

    test "is true when the Telemetry middleware appears before the PathParams middleware" do
      assert Appsignal.Tesla.path_params?([
               {Tesla.Middleware.Telemetry, nil},
               {Tesla.Middleware.PathParams, nil}
             ])
    end
  end

  describe "sanitise_url/3, with no base URL" do
    test "when use_full_path is false, it keeps the scheme, host and port" do
      assert "https://hex.pm" ==
               Appsignal.Tesla.sanitise_url(
                 "https://hex.pm/packages/appsignal",
                 nil,
                 false
               )
    end

    test "when use_full_path is true, it keeps the scheme, host, port and path" do
      assert "https://hex.pm/packages/appsignal" ==
               Appsignal.Tesla.sanitise_url(
                 "https://hex.pm/packages/appsignal",
                 nil,
                 true
               )
    end
  end

  describe "sanitise_url/3, with a base URL" do
    test "when the URL has a host, the base URL is ignored" do
      assert "https://appsignal.com" ==
               Appsignal.Tesla.sanitise_url(
                 "https://appsignal.com/docs",
                 "https://hex.pm/packages",
                 false
               )
    end

    test "when the URL does not have a host, the base URL's scheme, host, port and path are used" do
      assert "https://hex.pm/packages" ==
               Appsignal.Tesla.sanitise_url(
                 "/appsignal",
                 "https://hex.pm/packages",
                 false
               )
    end

    test "when use_full_path is true, the paths are joined" do
      assert "https://hex.pm/packages/:package" ==
               Appsignal.Tesla.sanitise_url(
                 "/:package",
                 "https://hex.pm/packages",
                 true
               )
    end
  end

  describe "env_middlewares/1" do
    test "it concatenates and normalises middlewares from the module and the client" do
      env =
        env(nil, [
          {Appsignal.FakeTeslaClientMiddleware, :call, :some_argument}
        ])

      assert Appsignal.Tesla.env_middlewares(env) == [
               # Normalised three element tuple middleware
               {Appsignal.FakeTeslaClientMiddleware, :some_argument},
               # Normalised two element tuple middleware
               {Appsignal.FakeTeslaBuilderMiddleware, nil}
             ]
    end

    test "it removes function adapters from the middleware chain" do
      env =
        env(nil, [
          {:fn, fn -> nil end},
          {:fn, fn _ -> nil end}
        ])

      assert Appsignal.Tesla.env_middlewares(env) == [
               {Appsignal.FakeTeslaBuilderMiddleware, nil}
             ]
    end
  end

  describe "tesla_request_start/4, without a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      :telemetry.execute(
        [:tesla, :request, :start],
        %{},
        %{env: env("https://hex.pm/packages/appsignal")}
      )
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "tesla_request_start/4, and tesla_request_stop/4 with a root span" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute([:tesla, :request, :start], %{}, %{env: env("https://example.com")})
      :telemetry.execute([:tesla, :request, :stop], %{}, %{})
    end

    test "creates a span with a parent" do
      assert {:ok, [{"http_request", %Span{}}]} = Test.Tracer.get(:create_span)
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "GET https://example.com"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category" do
      assert attribute?("appsignal:category", "request.tesla")
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "tesla_request_start/4, with the PathParams middleware" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute([:tesla, :request, :start], %{}, %{
        env:
          env("https://example.com/foo/:bar", [
            {Tesla.Middleware.Telemetry, :call, nil},
            {Tesla.Middleware.PathParams, :call, nil}
          ])
      })

      :telemetry.execute([:tesla, :request, :stop], %{}, %{})
    end

    test "sets the span's name with the URL's path" do
      assert {:ok, [{%Span{}, "GET https://example.com/foo/:bar"}]} = Test.Span.get(:set_name)
    end
  end

  describe "tesla_request_start/4, with the BaseUrl middleware" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute([:tesla, :request, :start], %{}, %{
        env:
          env("/bar", [
            {Tesla.Middleware.Telemetry, :call, nil},
            {Tesla.Middleware.BaseUrl, :call, ["https://example.com/foo"]}
          ])
      })

      :telemetry.execute([:tesla, :request, :stop], %{}, %{})
    end

    test "sets the span's name with the base URL" do
      assert {:ok, [{%Span{}, "GET https://example.com/foo"}]} = Test.Span.get(:set_name)
    end
  end

  describe "tesla_request_start/4, with the PathParams and BaseUrl middlewares" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute([:tesla, :request, :start], %{}, %{
        env:
          env("/:bar", [
            {Tesla.Middleware.Telemetry, :call, nil},
            {Tesla.Middleware.BaseUrl, :call, ["https://example.com/foo"]},
            {Tesla.Middleware.PathParams, :call, nil}
          ])
      })

      :telemetry.execute([:tesla, :request, :stop], %{}, %{})
    end

    test "sets the span's name with the base URL and the URL's path" do
      assert {:ok, [{%Span{}, "GET https://example.com/foo/:bar"}]} = Test.Span.get(:set_name)
    end
  end

  describe "tesla_request_exception/4" do
    setup do
      start_supervised!(Test.Nif)
      start_supervised!(Test.Tracer)
      start_supervised!(Test.Span)
      start_supervised!(Test.Monitor)

      Appsignal.Tracer.create_span("http_request")

      :telemetry.execute([:tesla, :request, :exception], %{}, %{})
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  defp env(url, client_middlewares \\ []) do
    %{
      __module__: Appsignal.FakeTeslaBuilder,
      __client__: %{
        pre: client_middlewares
      },
      method: :get,
      url: url
    }
  end

  defp attribute?(asserted_key, asserted_data) do
    {:ok, attributes} = Test.Span.get(:set_attribute)

    Enum.any?(attributes, fn {%Span{}, key, data} ->
      key == asserted_key and data == asserted_data
    end)
  end

  defp attached?(event) do
    event
    |> :telemetry.list_handlers()
    |> Enum.any?(fn %{id: id} ->
      id == {Appsignal.Tesla, event}
    end)
  end
end
