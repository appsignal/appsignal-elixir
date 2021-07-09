defmodule Appsignal.Agent do
  def version, do: "c2024bf"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4d705a05a9ebfcb5d592728f7ff002f939a89a63dca26c7db0c812a95f4c9902",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4d705a05a9ebfcb5d592728f7ff002f939a89a63dca26c7db0c812a95f4c9902",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "41e48b23ad55b55e49ec5940458c6a76f1e646311c0cfe56c8b4533bc60d7d97",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7b7f20576e77f8bd4e55e51804d5c60bf22bf1464ecf883b3fc43e8de5984f9b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7b7f20576e77f8bd4e55e51804d5c60bf22bf1464ecf883b3fc43e8de5984f9b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "c738a4daa41c9f068986e495625f732c5494b1458d1ef8a5d58da34fe3911c7d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "e6834abfcf1a3a99301f3184705c1d79602d76c63712e089abd53f44c1734962",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "decd1f7c7c8b8854bd9b32a993f5c2cea6076244f648bcfeccc063a608f7b5ea",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "decd1f7c7c8b8854bd9b32a993f5c2cea6076244f648bcfeccc063a608f7b5ea",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c2024bf/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
