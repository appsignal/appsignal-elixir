defmodule Appsignal.Agent do
  def version, do: "1816eff"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "d48013aca88cb59967e344507c14eab01d8b05a4506827d26d1dd2429d1188c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "d48013aca88cb59967e344507c14eab01d8b05a4506827d26d1dd2429d1188c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ceccd674e69084816f08607b6d1367ef934a4f10bea77588448b3227484e65a0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ceccd674e69084816f08607b6d1367ef934a4f10bea77588448b3227484e65a0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "77760b0277a3e965f33aac90ceda98d7832e9b24811b3b64fc1d176c1ee1215e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "77760b0277a3e965f33aac90ceda98d7832e9b24811b3b64fc1d176c1ee1215e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "80b5c83816b2a165afce209d70c51685487d0787a95828e52cf7de07a09ce8cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "694bb879d497a3501c79051cf4f1870602fc0cb78a2386837b80327f1d4dfa69",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ee7fbf68a7a1a8f8e2597f68fbb684f16df9b6c46c62c4f9f4255b9957486421",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ee7fbf68a7a1a8f8e2597f68fbb684f16df9b6c46c62c4f9f4255b9957486421",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1816eff/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
