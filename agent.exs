# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "d573c9b"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a9a86594e50f22e7f7fd93a050e334048248a6dc971015e66c26150c4a689345",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a9a86594e50f22e7f7fd93a050e334048248a6dc971015e66c26150c4a689345",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "92f7f71b685985b310a9f3693a96a5db6b9133b0af807d000b90248e097063c7",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "92f7f71b685985b310a9f3693a96a5db6b9133b0af807d000b90248e097063c7",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "92f7f71b685985b310a9f3693a96a5db6b9133b0af807d000b90248e097063c7",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "79f1e7f9c34ab36c06d5c3d676173ee7c1219af2f51dc77865897598dc01349a",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "835c6f823a2c6e9f8fa12704bf0953e3610dc9836355b57d2d6981e6ae412fb4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "835c6f823a2c6e9f8fa12704bf0953e3610dc9836355b57d2d6981e6ae412fb4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6eb6f0df2f8c62a29769bf7f21cefaec92a24ee0ab363acc5bd4f9c2d1241c53",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b16d46074527da5700e10e5a8b176aeb46b7bbb19431653029eda04437bef918",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "e7bfc1dc355ce1237aaee6fdf967c78ecca533db41b09c2b10716e7f8593dbe0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "e7bfc1dc355ce1237aaee6fdf967c78ecca533db41b09c2b10716e7f8593dbe0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
