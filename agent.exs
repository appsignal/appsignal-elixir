defmodule Appsignal.Agent do
  def version, do: "86b6269"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e253a63c279747c52013e7d0a9b402c879a345d5ab9c06c6f50314b6211d9e4e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e253a63c279747c52013e7d0a9b402c879a345d5ab9c06c6f50314b6211d9e4e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "11bf57ab3f845e41d90d4cf78fc727103c3a214dcbc18aecde9aa5f9bd0a105f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "11bf57ab3f845e41d90d4cf78fc727103c3a214dcbc18aecde9aa5f9bd0a105f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "fed88ea2a0a0885fd98e3f52a48b925aaca3946d39150dd9897af0b2a934660a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "fed88ea2a0a0885fd98e3f52a48b925aaca3946d39150dd9897af0b2a934660a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6d80a9d03c905926c14ba6ffd5d0d4c736a8d065c9055d8dd6d85e114f2a4d8e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "ecde0cc6349b68bf57a632f19a1e2f9fcdc42e8a9ce646fb1bd651837b06d01b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "4c880e9ef3f1a6da8cd9914ee2346422e6fb927772bd1586c4afbcf990023a69",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "4c880e9ef3f1a6da8cd9914ee2346422e6fb927772bd1586c4afbcf990023a69",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/86b6269/appsignal-x86_64-freebsd-all-static.tar.gz"
      }
    }
  end
end
