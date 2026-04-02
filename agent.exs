# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.11"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "9b4bfd1f7149511cd3a1525fe43c6e450688d6d44b25a769aa722a3260756eb6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "9b4bfd1f7149511cd3a1525fe43c6e450688d6d44b25a769aa722a3260756eb6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "95eb75d1c9d3c4f24edf94f88babc9daddeca8afc63ff0f85577128d3e5581b8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "95eb75d1c9d3c4f24edf94f88babc9daddeca8afc63ff0f85577128d3e5581b8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "95eb75d1c9d3c4f24edf94f88babc9daddeca8afc63ff0f85577128d3e5581b8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "eb3c3dc1842023a1959fb61d4ea711bd5439ba0268f124ec540eabb70d0343bb",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f4920fb2bf88b6cac45d85653e563ec4e7aaccb7456884db7170b5c0a8fc8a2d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f4920fb2bf88b6cac45d85653e563ec4e7aaccb7456884db7170b5c0a8fc8a2d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "66d53361ce71fb3dc9f9926969324ed35ea0adb650d6d422eaa194f084f6c375",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c72faa5d710d10b0906425123d455069950a920ac103641de053789fc8f874be",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "6b874662d6eb3c09226af88ba0726ec116ae29d8882719d2d9eecaff2e49feb9",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "14fb4946255ff9a327a873d70835458f3037fed0f984fc1d60a3ebfa11a3b6dd",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "14fb4946255ff9a327a873d70835458f3037fed0f984fc1d60a3ebfa11a3b6dd",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
