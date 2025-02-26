defmodule FakeFinch do
  def build(method, url, headers, body) do
    [method, url, headers, body]
  end

  def request([method, url, headers, body], _, options) do
    [method, url, headers, body, options]
  end
end
