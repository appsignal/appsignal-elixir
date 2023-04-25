# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "6f29190"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "022896c1f1e86376dab439b80c5c29075b8ee57e13bb53254b1d2724567e434d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "022896c1f1e86376dab439b80c5c29075b8ee57e13bb53254b1d2724567e434d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "551dfefd447ceb0bda5ea1d94cc2809296a5ae41789e96330fe9b88c4afe29f1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "551dfefd447ceb0bda5ea1d94cc2809296a5ae41789e96330fe9b88c4afe29f1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "551dfefd447ceb0bda5ea1d94cc2809296a5ae41789e96330fe9b88c4afe29f1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "860dc4079f1bf2a9608523bef8d0cb8b6fadff7e83332fc09658eeb5d32eb3bc",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "fbf5d2869c9cce9ac35cffee6b139bd8d9b01018a7173417febff7c77599a7b2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "fbf5d2869c9cce9ac35cffee6b139bd8d9b01018a7173417febff7c77599a7b2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8c4f2b96e2dd5c158bf46f46608901b9163998b6377a1795318ea9f366337eb1",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "2f3c5dfa997d9399032039e03ed8bd627892fecd3331367a3b83dc29d0c28497",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "abbc61bfe1009de9a7e11534647c7b60b38c2b35357e77356d7dfb1067acb4d0",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "d286e1338c80ec5e6f0104e53f27dfe420b3994eb7bb16ac4b32c06ec1405f33",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "d286e1338c80ec5e6f0104e53f27dfe420b3994eb7bb16ac4b32c06ec1405f33",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
