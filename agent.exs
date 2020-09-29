defmodule Appsignal.Agent do
  def version, do: "38010f3"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "138dda1564ea45604df8e829aac181a12368b780042ea8ea60dc9a7dcf56b6db",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "138dda1564ea45604df8e829aac181a12368b780042ea8ea60dc9a7dcf56b6db",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "628305aad5ae21c9b86d4481395d3c5145bfe017ecb3b6b3ccda52af17c381da",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "628305aad5ae21c9b86d4481395d3c5145bfe017ecb3b6b3ccda52af17c381da",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "1fe43790b8316731677e7ebc84f1b6ee7a20bff4fbc1652a94de811922c0c271",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a5d5343dfc63c60aa661e85a4edc1cac23fb82ea3033448ffbaa52e5ba5f06e8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c8d38647200ad6848072be61eb7b789aae25ed4f8e212e2a5afe910397bf2aaf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c8d38647200ad6848072be61eb7b789aae25ed4f8e212e2a5afe910397bf2aaf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/38010f3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
