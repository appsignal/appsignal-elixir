# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "7376537"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "108f022d9def20cea03aae52f9c07e8f35ef64a2c046edaad01a38966e1e45a7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "108f022d9def20cea03aae52f9c07e8f35ef64a2c046edaad01a38966e1e45a7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "0eacd24a3a053f2f80c8c7aeb7fafa9e851588ddbe798de8f40277b77e2819d5",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "0eacd24a3a053f2f80c8c7aeb7fafa9e851588ddbe798de8f40277b77e2819d5",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "0eacd24a3a053f2f80c8c7aeb7fafa9e851588ddbe798de8f40277b77e2819d5",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "e45c227bf87d855e0a94d3fcb42a96a4140458f796c67865c650ef3ff1275c57",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "52a6e693650710f1a8b2b389d4a3dc7194069a4eb507b02b068e05f60b92e790",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "52a6e693650710f1a8b2b389d4a3dc7194069a4eb507b02b068e05f60b92e790",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8ee5443ca68a3cbac7b63a079bfd734fffd84dbdeab1b9fae7379d7da544d096",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "4e01355da3a638bf1fefda47786323eb76345a49e77afab42d79df8510f52e07",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "6ba022dc3c66b3ff53316ef55b4841e329dc84c0c585dcd87314bcd9ffae9aab",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "6ba022dc3c66b3ff53316ef55b4841e329dc84c0c585dcd87314bcd9ffae9aab",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
