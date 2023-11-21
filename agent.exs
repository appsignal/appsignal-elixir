# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "eec7f7b"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "69da25f14fbfddffb83214355cda86955024f9f59ef6ac06faf223a475bdbbf7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "69da25f14fbfddffb83214355cda86955024f9f59ef6ac06faf223a475bdbbf7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "281e2daefeb513ea3c8af7cc58397753559606643ad2091bd5c5ba6b9a2a1aca",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "281e2daefeb513ea3c8af7cc58397753559606643ad2091bd5c5ba6b9a2a1aca",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "281e2daefeb513ea3c8af7cc58397753559606643ad2091bd5c5ba6b9a2a1aca",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "985ef69698d9cf44c4965f971043be9f65fa4ac825f30e7feca8a9fff210d65a",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4d5c3b4cdbcdd11cf78a3c62a57fef05ad1c62dd136289afcd184897af3ab1c5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4d5c3b4cdbcdd11cf78a3c62a57fef05ad1c62dd136289afcd184897af3ab1c5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "5db0bb195c4c5ff72352094d038ebfc75e0153b6fa54f285f6b0908bad20fea0",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "625fa055ae4944a4afe648a7a2e71e87a82384e96f93e56254b455b2ab049612",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "82ef1d0a98f6dfa81568dff539eb932973af5baaa6c737c4017faebf1aedf45e",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8fc180e5b3f77df90e4d1498d729e1fa2e8fa713689e92173d98ab69f4332557",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8fc180e5b3f77df90e4d1498d729e1fa2e8fa713689e92173d98ab69f4332557",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
