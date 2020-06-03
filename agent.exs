defmodule Appsignal.Agent do
  def version, do: "a21a12a"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "cb527ae259925fc9b34574304aa7c14cfd99d01841a09326d0a6d9afb9b2bf6e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "cb527ae259925fc9b34574304aa7c14cfd99d01841a09326d0a6d9afb9b2bf6e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "74908c9dbe97c5d59543d5a63a8882cb74a4931a361e70d875356f6c984fa350",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "74908c9dbe97c5d59543d5a63a8882cb74a4931a361e70d875356f6c984fa350",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "8214cc5022d1840218d5639c6b04ff2676c7c973de2fb9208b5082cfc6686a40",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "8214cc5022d1840218d5639c6b04ff2676c7c973de2fb9208b5082cfc6686a40",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8d5601c1266aba83f4a187801d7389e023883f87f6471bfacc856f0695593d53",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "9aa456d9ca09650d3f8ab280e48e928890c08e28372fa2f2ef6546003bee4436",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "e36c16050c733674a7abe47dff54706738b241158c049947892ec1b413bacf01",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "e36c16050c733674a7abe47dff54706738b241158c049947892ec1b413bacf01",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a21a12a/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
