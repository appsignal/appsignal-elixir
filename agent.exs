# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "d789895"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8ea76b7d011c728b7988d017a39fc3a432d9c86392e6e46767ecc931e583777a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8ea76b7d011c728b7988d017a39fc3a432d9c86392e6e46767ecc931e583777a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "535fed60ac1484e40bbfe77cd4fe9131c67f25e6362a2fe31d987c36ec82ba08",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "535fed60ac1484e40bbfe77cd4fe9131c67f25e6362a2fe31d987c36ec82ba08",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "535fed60ac1484e40bbfe77cd4fe9131c67f25e6362a2fe31d987c36ec82ba08",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "35f96e0adf408fd8ac3e89c6cb3c5506eb4250643199aad3ba298ab131d773c8",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f4a1c9a67a0a4cde7e13ef555a6782e5d4f15bfbce9277c2aaf8e248a0fb858e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f4a1c9a67a0a4cde7e13ef555a6782e5d4f15bfbce9277c2aaf8e248a0fb858e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "016c962727e31a07eee7a221944ff9c4bbb054eada7e87bbe4602233364f380c",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "2ce9e34b283c76c6b25028d3a770a942f4975cd071c586438a8765948237ca42",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "017da79e62a2875c0384898c9160cd83acd712faba05154fd8a0627fec1b5ba4",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "13d27afcb68aff5e164e05fc4fd8874e73f14c0154301f2e6e6e75f67fa9182c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "13d27afcb68aff5e164e05fc4fd8874e73f14c0154301f2e6e6e75f67fa9182c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
