# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.7"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "18e94eb2750e9ed6cd31c00af684759abd32254b1db4c02af46e166b5346245b",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "18e94eb2750e9ed6cd31c00af684759abd32254b1db4c02af46e166b5346245b",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "ca261c4422d5daadeff300512b9d3c466c5174113b7f3fcda36b28f8a51c1e43",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "ca261c4422d5daadeff300512b9d3c466c5174113b7f3fcda36b28f8a51c1e43",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "ca261c4422d5daadeff300512b9d3c466c5174113b7f3fcda36b28f8a51c1e43",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "aa2ab16361ab3d2709f050d7f83b5ba4c82c6e67e2b50201422147d6c266e205",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ccbf51c5cc63c8812c40256853994fed8d20e48f78d60be3b4100ee1479bde95",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ccbf51c5cc63c8812c40256853994fed8d20e48f78d60be3b4100ee1479bde95",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "59fa4c2b31f5f728174a7df66e034281c8b00b590ad4a69905e0e8d9ff8f4887",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "11d511eec05d257c8870e58845bd608760335cdb4e961dad0f62447cf94325a6",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "ac01b551ba723a5b51e4d14a2bf9da98cb70a4e6931976147ff5b7a570a4a631",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "a44e9498311c116f0cb0c404c1daaa8e1b3a4d759f0d93c5fee69824a86dfe37",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "a44e9498311c116f0cb0c404c1daaa8e1b3a4d759f0d93c5fee69824a86dfe37",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
