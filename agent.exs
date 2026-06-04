# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.12"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a63189a2ba6b500e038e5658f97478ceae27a956baa2f89a4e79ee5a1dadace6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a63189a2ba6b500e038e5658f97478ceae27a956baa2f89a4e79ee5a1dadace6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "d23d6cc15e7df1c810b55dc33905002c5a1d6bc3f7cb10690d7e21398aabdac0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "d23d6cc15e7df1c810b55dc33905002c5a1d6bc3f7cb10690d7e21398aabdac0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "d23d6cc15e7df1c810b55dc33905002c5a1d6bc3f7cb10690d7e21398aabdac0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0a277e682f1568fbc54df849a46f21f155643b40c285a5bd30294c9d046e49c2",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0d4536a2b1c9b6915f0f8597bd858988e284e7dbc4a14488332ffa7e401a1134",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0d4536a2b1c9b6915f0f8597bd858988e284e7dbc4a14488332ffa7e401a1134",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "eec59a3e46dd5d5baff044465b4e314f21edf6270500bf24e3bc50afcee5f2e2",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "4454ec095ad14813bedea20a110a26235dbc6e8e33538219fad325792c0d888e",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "048a55f0f10087e7954559d6cd09b371a0b532673f7ca769bcfde5729e297a72",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "d81d039a3c1936bd393a6140b46f48092da31600b0311eab819acd777521a588",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "d81d039a3c1936bd393a6140b46f48092da31600b0311eab819acd777521a588",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
