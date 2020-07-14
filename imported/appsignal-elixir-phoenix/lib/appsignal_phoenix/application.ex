defmodule Appsignal.Phoenix.Application do
  alias Appsignal.Phoenix.EventHandler

  @moduledoc false

  use Application

  def start(_type, _args) do
    EventHandler.attach()

    opts = [strategy: :one_for_one, name: Appsignal.Phoenix.Supervisor]
    Supervisor.start_link([], opts)
  end
end
