# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "be3107a"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "31b13af931f26832eb9b5f3283a0dcfc83e327a31570aef47704589de5bd54cc",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "31b13af931f26832eb9b5f3283a0dcfc83e327a31570aef47704589de5bd54cc",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "902649453b5cfe86dee86f053a7dbe7df35bc8bce0b9632bd5619a8c824f02af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "902649453b5cfe86dee86f053a7dbe7df35bc8bce0b9632bd5619a8c824f02af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "902649453b5cfe86dee86f053a7dbe7df35bc8bce0b9632bd5619a8c824f02af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "37819d1df9b516d39a3aaf54bcc434f7d77e0067d75a86fff8c89be24cf16c28",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c372daebb69e9795c8dcd60f48cad2af66628e1e3c8211f00526bdc8c880fc97",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c372daebb69e9795c8dcd60f48cad2af66628e1e3c8211f00526bdc8c880fc97",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "972a8b02061d747fbe35f3dd8d3d5b7c34bf7a6a38d0526d0ff55b9e70b67f13",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "4821b9d4e9b4501a5002f731b633a64b3991272fb0e6e57a61ce1e2a0b33bcad",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2b8ff925dd40daab892cf66ad3fefb72559cab57433907d8f70ae41722716832",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2b8ff925dd40daab892cf66ad3fefb72559cab57433907d8f70ae41722716832",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
