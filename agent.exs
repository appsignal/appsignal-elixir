defmodule Appsignal.Agent do
  def version, do: "e1f368f"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "951dd5f34dcef9d4c6b9194787535c719e7ad90cbbca0b42f878c7e3310ea810",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "951dd5f34dcef9d4c6b9194787535c719e7ad90cbbca0b42f878c7e3310ea810",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "60ada4d99e77409a965dd5ddf142d9147499caa631c793bf1ee6cf9ab88d189e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "60ada4d99e77409a965dd5ddf142d9147499caa631c793bf1ee6cf9ab88d189e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "3dc981df4390e67e6f27ec51b59168258ffef597bbd491a7b7ec8e4c1f701db8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "3dc981df4390e67e6f27ec51b59168258ffef597bbd491a7b7ec8e4c1f701db8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "5c00340c453ea1a3809015c47e2b5138c38350341424ee10a4eb571f1f77f74c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c238799132e2f9127622e9ca8611ff492d2cdc8c3f82138cd5d00a5ef281b2b4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "a5fd97116f64ea349c1ed4ce9b1dacfe77caf81e2a8491116295fe399aac2af9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "a5fd97116f64ea349c1ed4ce9b1dacfe77caf81e2a8491116295fe399aac2af9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1f368f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
