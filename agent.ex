defmodule Appsignal.Agent do
  def version, do: "1e9d96e"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "eb9101280bd1c8bbe7b91404fd64db04f854549557cf131d14be5dc25e905820",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1e9d96e/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "cfb64011566530469d0a80dce252bcbb30549cecfe08eee7c7abafc917758c12",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1e9d96e/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "cfb64011566530469d0a80dce252bcbb30549cecfe08eee7c7abafc917758c12",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1e9d96e/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "038e71a9ebb348250e7f46c3884cdb79b3526e2eaa2a0e2189294c21099c2dcc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1e9d96e/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "038e71a9ebb348250e7f46c3884cdb79b3526e2eaa2a0e2189294c21099c2dcc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1e9d96e/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
