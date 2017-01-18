defmodule Appsignal.SystemBehaviour do
  @callback hostname_with_domain() :: String.t | nil
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
end
