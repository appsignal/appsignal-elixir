defmodule Appsignal.Transmitter do
  def request(method, url, headers \\ [], body \\ "") do
    :application.ensure_all_started(:hackney)

    :hackney.request(method, url, headers, body)
  end
end
