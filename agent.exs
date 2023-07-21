# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "ceaca3b"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "00f1b2c0b79827ce1abb751005221c4852787ca1804ebcd7e2634714d146ffe0",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "00f1b2c0b79827ce1abb751005221c4852787ca1804ebcd7e2634714d146ffe0",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "e9195d0aa4e22214eeb2dcb54651014db09f2b84f5f5ef41f6c7fcddb9b58384",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "e9195d0aa4e22214eeb2dcb54651014db09f2b84f5f5ef41f6c7fcddb9b58384",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "e9195d0aa4e22214eeb2dcb54651014db09f2b84f5f5ef41f6c7fcddb9b58384",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "d568c447595d5a46b726c09c44c66a28153bb85b843d9f915e755de60d2cc797",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4a8135e861ef8dd347ada22fa1fc993d1c5ba5db7f9f043a38fb9891c57368a5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4a8135e861ef8dd347ada22fa1fc993d1c5ba5db7f9f043a38fb9891c57368a5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4a22f454e5c125cd24436ad331d53df965394be81272c8ab366a2e6ea5f02625",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d770f78f9f87d3b5b01a93f0e3f0dffc36a4f8bd664ce37574fd0671276d4d8b",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "ef4838e0cd3e43d0cc138e0eb6b78b7cf1f29244daa8379bb30c47b1497f5570",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f1730afd98b48f3fa938fd07b27dc470e7dcd3f8d2e72a7a0fc2a4b080461f5b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f1730afd98b48f3fa938fd07b27dc470e7dcd3f8d2e72a7a0fc2a4b080461f5b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
