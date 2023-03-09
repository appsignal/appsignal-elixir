# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "dee4fcb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "d45bfc2eb38138c317b501c3156459b8dbbb15a59910f1e2ec3d2d02e461a147",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "d45bfc2eb38138c317b501c3156459b8dbbb15a59910f1e2ec3d2d02e461a147",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "1cd875e74ba18c2bc81533437a9eebdf08f624e0201427c13326c2be00f22907",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "1cd875e74ba18c2bc81533437a9eebdf08f624e0201427c13326c2be00f22907",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "1cd875e74ba18c2bc81533437a9eebdf08f624e0201427c13326c2be00f22907",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "72fbfaa1c6ed72defea9eca59679372f53ddeab845a9b2f75d9d165e4983d69e",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c504a7233512c9285274a7ba0142ab91cf4637c6f5f57c58c6890137ba0f82de",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c504a7233512c9285274a7ba0142ab91cf4637c6f5f57c58c6890137ba0f82de",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "f9e68dbbee7d38b255c5b9bc0cb75226764f79cd51421e4e00a9e7454b0c6ccb",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "8fa1d110d2544502509cc66ba8ec6685010d8c6d8373f4f14ebe721d4be157e0",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "a43895183baf017879332885a904208773befc14b9bd628efae6d1513052b782",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "1b992f770bdbced09f7b5f18d7aa721710218d4a76a131adc7affe44d68684f0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "1b992f770bdbced09f7b5f18d7aa721710218d4a76a131adc7affe44d68684f0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
