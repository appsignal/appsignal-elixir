defmodule Appsignal.Agent do
  def version, do: "7ade8ff"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "4c9a40b6215aa5598f546050817448e698479a2e6594feb8f7d46b755ae959e9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7ade8ff/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "0caf5d0ef96f663b03b36d4c37741856ded851d205e0c1403550d6c04266eb6b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7ade8ff/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "0caf5d0ef96f663b03b36d4c37741856ded851d205e0c1403550d6c04266eb6b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7ade8ff/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "bc72d9f7485b66802f9642e1d2fee4d2fe2f1b5b363f1378c46469d112b9442e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7ade8ff/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "bc72d9f7485b66802f9642e1d2fee4d2fe2f1b5b363f1378c46469d112b9442e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7ade8ff/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
