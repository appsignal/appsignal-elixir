defmodule Appsignal.GenServer do
  defmacro __using__(args) do
    quote do
      use Elixir.GenServer, unquote(args)

      def handle_call({Appsignal.GenServer, request}, from, state) do
        span_name = Appsignal.GenServer.Utils.handle_name("call", __MODULE__, request)

        Appsignal.instrument(span_name, "handle_call.genserver", fn span ->
          Appsignal.Span.set_namespace(span, "genserver")

          try do
            Appsignal.GenServer.Utils.wrap_continue(handle_call(request, from, state))
          catch
            kind, reason ->
              Appsignal.set_error(kind, reason, __STACKTRACE__)
              :erlang.raise(kind, reason, __STACKTRACE__)
          end
        end)
      end

      def handle_cast({Appsignal.GenServer, request}, state) do
        span_name = Appsignal.GenServer.Utils.handle_name("cast", __MODULE__, request)

        Appsignal.instrument(span_name, "handle_cast.genserver", fn span ->
          Appsignal.Span.set_namespace(span, "genserver")

          try do
            Appsignal.GenServer.Utils.wrap_continue(handle_cast(request, state))
          catch
            kind, reason ->
              Appsignal.set_error(kind, reason, __STACKTRACE__)
              :erlang.raise(kind, reason, __STACKTRACE__)
          end
        end)
      end

      def handle_continue({Appsignal.GenServer, request}, state) do
        span_name = Appsignal.GenServer.Utils.handle_name("continue", __MODULE__, request)

        Appsignal.instrument(span_name, "handle_continue.genserver", fn span ->
          Appsignal.Span.set_namespace(span, "genserver")

          try do
            Appsignal.GenServer.Utils.wrap_continue(handle_continue(request, state))
          catch
            kind, reason ->
              Appsignal.set_error(kind, reason, __STACKTRACE__)
              :erlang.raise(kind, reason, __STACKTRACE__)
          end
        end)
      end

      def init({Appsignal.GenServer, init_arg}) do
        try do
          Appsignal.GenServer.Utils.wrap_continue(init(init_arg))
        catch
          kind, reason ->
            Appsignal.send_error(kind, reason, __STACKTRACE__, fn span ->
              Appsignal.Span.set_namespace(span, "genserver")
              Appsignal.Span.set_name(span, "#{inspect(__MODULE__)}.init")
            end)
            :erlang.raise(kind, reason, __STACKTRACE__)
        end
      end
    end
  end

  defdelegate abcast(nodes \\ [node() | Node.list()], name, request), to: Elixir.GenServer
  defdelegate multi_call(nodes \\ [node() | Node.list()], name, request, timeout \\ :infinity), to: Elixir.GenServer
  defdelegate reply(client, reply), to: Elixir.GenServer
  defdelegate stop(server, reason \\ :normal, timeout \\ :infinity), to: Elixir.GenServer
  defdelegate whereis(server), to: Elixir.GenServer

  def call(server, request, timeout \\ 5000) do    
    if Appsignal.Tracer.current_span() do
      span_name = Appsignal.GenServer.Utils.invoke_name("call", server, request)

      Appsignal.instrument(span_name, "call.genserver", fn ->
        Elixir.GenServer.call(server, {Appsignal.GenServer, request}, timeout)
      end)
    else
      Elixir.GenServer.call(server, {Appsignal.GenServer, request}, timeout)
    end
  end

  def cast(server, request) do
    if Appsignal.Tracer.current_span() do
      span_name = Appsignal.GenServer.Utils.invoke_name("cast", server, request)

      Appsignal.instrument(span_name, "cast.genserver", fn ->
        Elixir.GenServer.cast(server, {Appsignal.GenServer, request})
      end)
    else
      Elixir.GenServer.cast(server, {Appsignal.GenServer, request})
    end
  end

  def start(module, init_arg, options \\ []) do
    Elixir.GenServer.start(module, {Appsignal.GenServer, init_arg}, options)
  end

  def start_link(module, init_arg, options \\ []) do
    Elixir.GenServer.start_link(module, {Appsignal.GenServer, init_arg}, options)
  end
end

defmodule Appsignal.GenServer.Utils do
  def wrap_continue(return) do
    case return do
      {:reply, reply, state, {:continue, request}} ->
        wrap_continue({:reply, reply, state, {:continue, {Appsignal.GenServer, request}}}, request)
      {:noreply, state, {:continue, request}} ->
        wrap_continue({:noreply, state, {:continue, {Appsignal.GenServer, request}}}, request)
      {:ok, state, {:continue, request}} ->
        wrap_continue({:ok, state, {:continue, {Appsignal.GenServer, request}}}, request)
      any -> any
    end
  end

  defp wrap_continue(wrapped_return, request) do
    if Appsignal.Tracer.current_span() do
      span_name = Appsignal.GenServer.Utils.invoke_continue(request)

      Appsignal.instrument(span_name, "continue.genserver", fn ->
        wrapped_return
      end)
    else
      wrapped_return
    end
  end

  def invoke_continue(request) do
    "{:continue, #{request_name(request)}}"
  end

  def invoke_name(method, server, request) do
    "GenServer.#{method}(#{server_name(server)}, #{request_name(request)})"
  end

  def handle_name(method, server, request) do
    "#{server_name(server)}.#{method}(#{request_name(request)})"
  end

  defp request_name(request) when is_atom(request), do: inspect(request)

  defp request_name(request)
    when is_tuple(request)
    and tuple_size(request) > 1
    and is_atom(elem(request, 0)) do
    "{#{inspect(elem(request, 0))}, ...}"
  end

  defp request_name(request)
    when is_tuple(request)
    and tuple_size(request) == 1
    and is_atom(elem(request, 0)) do
    "{#{inspect(elem(request, 0))}}"
  end

  defp request_name(request) when is_struct(request), do: "%#{inspect(request.__struct__)}{...}"
  defp request_name(_request), do: "..."

  defp server_name(server) when is_pid(server), do: "#PID<...>"
  defp server_name(server) when is_port(server), do: "#Port<...>"
  defp server_name(server) when is_atom(server), do: inspect(server)
  defp server_name({:via, _module, _name} = server), do: inspect(server)
  defp server_name({:global, _term} = server), do: inspect(server)

  defp server_name(server)
    when is_tuple(server)
    and tuple_size(server) > 1 do
    "{#{inspect(elem(server, 0))}, ...}"
  end
  
  defp server_name(_server), do: "..."
end
