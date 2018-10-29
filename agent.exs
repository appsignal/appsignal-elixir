defmodule Appsignal.Agent do
  def version, do: "0830491"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e54dc97f43781c0227b2f15640060c7318153564105f48b835956a0a00271d7e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e54dc97f43781c0227b2f15640060c7318153564105f48b835956a0a00271d7e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5d07d9ef6273c02328dd96334d69f8809ea00cd1e2f09b2ffa6765b530029b10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5d07d9ef6273c02328dd96334d69f8809ea00cd1e2f09b2ffa6765b530029b10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "cc30d74b5f80ce334699459e69d38788156633e95343d448f1f16af3d06c4819",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "cc30d74b5f80ce334699459e69d38788156633e95343d448f1f16af3d06c4819",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "dbbf73b16afd49670f7ec4fd574ed17510c1c96d073faee1d496f56b49bc7515",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "e0591c948590b6ef96b243a826dd176ec4466f326eef44b71a2a4322d9b6358d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f5e75c689cc25ec37315fb68c0c4d849f1b9987e675272652cb6ce3b3d785257",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f5e75c689cc25ec37315fb68c0c4d849f1b9987e675272652cb6ce3b3d785257",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0830491/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
