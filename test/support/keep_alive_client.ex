defmodule AppsignalTest.KeepAliveClient do
  @moduledoc """
  An HTTP/1.1 client that sends its requests one after another over a single
  connection, so a server that serves a connection from one process serves
  them all from that process. `:httpc` can open a new connection for any
  request.

  The connection stays open until the calling process exits: Cowboy stops
  the process serving a request when its connection closes, even when that
  process has sent its response and is still running. Responses must have a
  `content-length` header.
  """

  @doc "Sends a GET request for each path, in order, and returns their statuses."
  def get(port, paths) do
    {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

    Enum.map(paths, fn path ->
      :ok = :gen_tcp.send(socket, "GET #{path} HTTP/1.1\r\nhost: localhost\r\n\r\n")
      read_response(socket, "")
    end)
  end

  defp read_response(socket, received) do
    case String.split(received, "\r\n\r\n", parts: 2) do
      [head, body] ->
        ["HTTP/1.1 " <> status | headers] = String.split(head, "\r\n")
        read_body(socket, byte_size(body), content_length(headers))
        status |> String.slice(0, 3) |> String.to_integer()

      [_incomplete] ->
        {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
        read_response(socket, received <> data)
    end
  end

  defp content_length(headers) do
    Enum.find_value(headers, fn header ->
      case String.split(header, ":", parts: 2) do
        [name, value] ->
          String.downcase(name) == "content-length" && String.to_integer(String.trim(value))

        _ ->
          nil
      end
    end)
  end

  defp read_body(_socket, received, length) when received >= length, do: :ok

  defp read_body(socket, received, length) do
    {:ok, _data} = :gen_tcp.recv(socket, length - received, 5_000)
    :ok
  end
end
