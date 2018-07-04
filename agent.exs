defmodule Appsignal.Agent do
  def version, do: "e801925"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e567535a3a2aa7760d6e9fffe62ffe36c1d1544a0ace8b04aaac344ccf6f73ed",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e567535a3a2aa7760d6e9fffe62ffe36c1d1544a0ace8b04aaac344ccf6f73ed",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "17687fb55bf84f5ed219fabd000c101afac5664408babfd4d7b7d5b27ce4008f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "17687fb55bf84f5ed219fabd000c101afac5664408babfd4d7b7d5b27ce4008f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "15cfe0fd8f50882cd93b245ffee25d8e9122ee64a29cedbde6a11e9720acf06c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "15cfe0fd8f50882cd93b245ffee25d8e9122ee64a29cedbde6a11e9720acf06c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "b5d711f5f93be49295a2b7a568d990b148db1e1e17bbc95f7038dc10037b64c2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b1761ecbba65eefe1e2b168a41692e82f65781e2b3179277733ae9889d766cdb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "0fecd3891dd9d5f152c06bc960c270274a83df8f8cee6f5698256bb78f1eb3e6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "0fecd3891dd9d5f152c06bc960c270274a83df8f8cee6f5698256bb78f1eb3e6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e801925/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
