# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "15ee07b"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "59bb7f5aea47ccea89b48cc323371fd87609592945ae8692f36063a635970e22",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "59bb7f5aea47ccea89b48cc323371fd87609592945ae8692f36063a635970e22",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "aa37596a85d65d46fc5bba25d4d059e98655709e6c44ee39e7c6ba72398ad704",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "aa37596a85d65d46fc5bba25d4d059e98655709e6c44ee39e7c6ba72398ad704",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "aa37596a85d65d46fc5bba25d4d059e98655709e6c44ee39e7c6ba72398ad704",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "12c5659d5a5d67ee641bdb1c38ef842b7687811fdec1f9edf8e196a2ed596405",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "afebd51e26b8d21923a8adcbc8fda7bbd29d4e12573f53895e3a650fcd84ffd5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "afebd51e26b8d21923a8adcbc8fda7bbd29d4e12573f53895e3a650fcd84ffd5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "563eb5c9daeec67a760ac236b2848aee4ec0e39dca1368150a6d99844d4d665f",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "2ecad2b2bdd362d9d871322eac79370d12314e3d32a53c83be17d054e91f188d",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2eaa4beeb3322ec3c6007f4a8ec483405f8ade4c372031a068bbedf05da9443d",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2eaa4beeb3322ec3c6007f4a8ec483405f8ade4c372031a068bbedf05da9443d",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
