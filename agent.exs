# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "debb8cf"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "7597130ddfeac866b4eea69348d446603b19b25c9ebd0714a3c39546d0cb6bc3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "7597130ddfeac866b4eea69348d446603b19b25c9ebd0714a3c39546d0cb6bc3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "e4b4f0f3d75b576411f5fa16e1257bde2e21efcd9cadae3a05d22bbb0e094e09",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "e4b4f0f3d75b576411f5fa16e1257bde2e21efcd9cadae3a05d22bbb0e094e09",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "e4b4f0f3d75b576411f5fa16e1257bde2e21efcd9cadae3a05d22bbb0e094e09",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "1cfd0b66000d32e10529b61c78c2f96c217a0f1eb40ddb12869c36ba8595f94c",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4f90a840931a9c4d0bc0b90b5a20268a0f67e87b1d9cdc4f58f874e8077e96ab",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4f90a840931a9c4d0bc0b90b5a20268a0f67e87b1d9cdc4f58f874e8077e96ab",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "bbb7e29a20384ecc848291a2637ecb2653a0020a62606c19b631dbe8e04d6089",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "69b48e0bcacbc1f2bf642800a7d5be2cf5031f2fabe567c39ac0faaa0143d8fb",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "0db801296acce9ff11ca19a14c4a113d30e2f155fcc790af75b80a0013503484",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "bba6e8f2d5492ef15a5623ee606c91d4db726f917bb2f7e86fe26afc880cafb3",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "bba6e8f2d5492ef15a5623ee606c91d4db726f917bb2f7e86fe26afc880cafb3",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
