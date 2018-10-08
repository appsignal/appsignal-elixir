defmodule FakeHackney do
  def request(method, url, headers, body, options) do
    [method, url, headers, body, options]
  end
end
