defmodule Appsignal.SystemBehaviour do
  @callback hostname_with_domain() :: String.t | nil
  @callback root?() :: boolean()
  @callback heroku?() :: boolean()
  @callback uid() :: integer | nil
end

defmodule Appsignal.System do
  @behaviour Appsignal.SystemBehaviour

  @doc """
  Get the full host name, including the domain.
  """
  def hostname_with_domain do
    case :inet_udp.open(0) do
      {:ok, port} ->
        {:ok, hostname} = :inet.gethostname(port)
        :inet_udp.close(port)
        to_string(hostname)
      _ -> nil
    end
  end

  def heroku? do
    System.get_env("DYNO") != nil
  end

  def root? do
    uid() == 0
  end

  def uid do
    case System.cmd("id", ["-u"]) do
      {id, 0} ->
        case Integer.parse(List.first(String.split(id, "\n"))) do
          {int, _} -> int
          :error -> nil
        end
      {_, _} -> nil
    end
  end
end
