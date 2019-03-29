defmodule Appsignal.Agent do
  def version, do: "d8dc806"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a2cc43f4fd296a6a3db06096030185c7cfbdde701b19c1580b44ee5c1bdbef95",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a2cc43f4fd296a6a3db06096030185c7cfbdde701b19c1580b44ee5c1bdbef95",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ac048bc96c05b4662d8959d2bb7c9028ba9a6fcd78f08cd284457dba8db4e0fc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ac048bc96c05b4662d8959d2bb7c9028ba9a6fcd78f08cd284457dba8db4e0fc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "c61e68128fd8adc3f19917eb4c82a2cd4887f71c96fb5c20a281867841cc6020",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "c61e68128fd8adc3f19917eb4c82a2cd4887f71c96fb5c20a281867841cc6020",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "525349f02f3d089bbac237d79b50ec5a6b503354b26ec20638d4a15aae79c635",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "133f5f29f38e0d4bf946b8b7290b848efef580ab0f5480790db766653614b0cf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b241082609ad39f26b16094f3f43b113c4eb45340e5b59adae2b365c605b9a8c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b241082609ad39f26b16094f3f43b113c4eb45340e5b59adae2b365c605b9a8c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d8dc806/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
