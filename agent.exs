# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "bbc830a"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "5e817193bb57f13ff16bacceda459d8badc2d5a04a6b131a7bb343212329304a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "5e817193bb57f13ff16bacceda459d8badc2d5a04a6b131a7bb343212329304a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "d443e00232acd3e53cd3d3f8c525da69ad362c38230472cc596e687cf73c7d94",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "d443e00232acd3e53cd3d3f8c525da69ad362c38230472cc596e687cf73c7d94",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "d443e00232acd3e53cd3d3f8c525da69ad362c38230472cc596e687cf73c7d94",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "7cd884dfd47466112d571ce49830057ffff0070383037eec4bfecf29547e3e47",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "21ca02f85c438190307b2a3500642a94dbd35ada6349cd97ac32253ac7dcc9e1",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "21ca02f85c438190307b2a3500642a94dbd35ada6349cd97ac32253ac7dcc9e1",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6feb2ed89451c6fdf6365dd1023bd419d8fa99e3c986d6a4e804f8cb68b3f401",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "61a70bb104b7d7cbb9d51a0a5d806346a6c36deb60d1e41351eb61c4813587c1",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8662a282787b11a6e48dab944afbf1afca91b45ca3147de8cdadb52ef271a43a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8662a282787b11a6e48dab944afbf1afca91b45ca3147de8cdadb52ef271a43a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
