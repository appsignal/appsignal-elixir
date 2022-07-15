# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "475541d"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "ab8efddd84d1245a47d7380fcd28821a01fd3dcfc7461e4b37d5b4d63fe405ab",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "ab8efddd84d1245a47d7380fcd28821a01fd3dcfc7461e4b37d5b4d63fe405ab",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "7756b040b7946d8acdac13f53e6ee9609c22535003cbf3d1ab91d742a5948410",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "7756b040b7946d8acdac13f53e6ee9609c22535003cbf3d1ab91d742a5948410",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "7756b040b7946d8acdac13f53e6ee9609c22535003cbf3d1ab91d742a5948410",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "563ff84e0903da7fca9f2ec56d5bed2e8e9f67338cfe858588ef068dec24f7c2",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "b9d15cec375b42cb82603c5b76b967d7dddc952ed4675e31290cdd772d07a9d2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "b9d15cec375b42cb82603c5b76b967d7dddc952ed4675e31290cdd772d07a9d2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d08d23d9e7338a14859f4b6ab13ae6d045040e9a7cc1075855f2d07e756dbc20",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "9afd75fa88ba5e6119c75c9a100dfa2785982243d2cc71add231317c5819fdcf",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "1a1048394c1448df9a2410d6919940248d041aaf870bd2686bf24fdb829b7c61",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "1a1048394c1448df9a2410d6919940248d041aaf870bd2686bf24fdb829b7c61",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
