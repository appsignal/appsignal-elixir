defmodule Appsignal.Phoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Appsignal.Phoenix.EventHandler.attach()

    opts = [strategy: :one_for_one, name: Appsignal.Phoenix.Supervisor]
    Supervisor.start_link([], opts)
  end
end
