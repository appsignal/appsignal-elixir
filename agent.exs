defmodule Appsignal.Agent do
  def version, do: "7859eb4"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "7297a066ced652e7ec498eee30b9094586b5d0ce221c84bbb851e2de9d11a39f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "7297a066ced652e7ec498eee30b9094586b5d0ce221c84bbb851e2de9d11a39f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "002b5d27e368444eae4308e97285faa83f13cb2aa25fde32a39000d354649917",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "002b5d27e368444eae4308e97285faa83f13cb2aa25fde32a39000d354649917",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "038b14bf3f3cad55e3dfc4947a6eccaf90f2cb15574f2cc69b17f78b20f8075e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "038b14bf3f3cad55e3dfc4947a6eccaf90f2cb15574f2cc69b17f78b20f8075e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d968a93822a61d39a62648c2880e52bdb4caba81c567041d27da7a3c848650b7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "669d0876ae3bb5033563c19aed63c298beca3dd4c2d06c3fa27d641c650b8654",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "9f02f723ceef3f5ebb68f226bb6f188b8f3e07551684b86f3eb37f918d549148",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "9f02f723ceef3f5ebb68f226bb6f188b8f3e07551684b86f3eb37f918d549148",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7859eb4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
