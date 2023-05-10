# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "6ac961d"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "f9da1f120dd09c57f236d3f442a24dc6f91104f87217ce3227c763386fb80608",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "f9da1f120dd09c57f236d3f442a24dc6f91104f87217ce3227c763386fb80608",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "e2a7ed02f628389cce6da7b0854abb0a88a11d4ed5464aaa4de6b57d914f4049",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "e2a7ed02f628389cce6da7b0854abb0a88a11d4ed5464aaa4de6b57d914f4049",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "e2a7ed02f628389cce6da7b0854abb0a88a11d4ed5464aaa4de6b57d914f4049",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0c54cf8fd771c1ab4a8296dadd3310ab22ba3a2d1de0e21045c54bd7d5ddbbcc",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c1df0c787ff637e5583e233a348c713e207691dd9a76cf9f13395cd47a24eca8",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c1df0c787ff637e5583e233a348c713e207691dd9a76cf9f13395cd47a24eca8",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "3b4d6bc3f6bf81f6036c3eadeb7d085cae08dbdc90948d95dad82106e5ba40d9",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c429a06360396a7a81d4c2a45f5ac4a50a7dd48c43f745fd4df0e3ad2c0c3745",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "0919bd046151966d53332025bc2c25245ab2f50c7146556d7f1ba0f898922cd9",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "892ab353756631be9cc763a78031755e72880dd9b9f2d1b9efc553cb3f282c41",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "892ab353756631be9cc763a78031755e72880dd9b9f2d1b9efc553cb3f282c41",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
