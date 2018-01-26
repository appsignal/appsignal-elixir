defmodule Appsignal.Agent do
  def version, do: "ee63235"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "44566908e93a31fbbc5f4ba35f41de99947c3c748287283600868fbbe5c18338",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "44566908e93a31fbbc5f4ba35f41de99947c3c748287283600868fbbe5c18338",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "85d4ac72aaed0b08226fc5a12fe210f2789d97bc162e15d8d36273c3936a5e19",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "85d4ac72aaed0b08226fc5a12fe210f2789d97bc162e15d8d36273c3936a5e19",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "59beb7c8b7b6e3ade4f654e300aa53cb0a7d9bbbd547257b52d2e19c49ddb6d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "59beb7c8b7b6e3ade4f654e300aa53cb0a7d9bbbd547257b52d2e19c49ddb6d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "a05243504688705d93caf105da29ecbca6b190eb2cd9b0f09673aacd4824d435",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "9ddbc05f47776d712e58be84f0d31fe1cb23eeab90afe79a2724db13b1471ba4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b7200bf705cdbafad2d62f24554f90a7f317ad9fc4121e9a8a33f36bf1060215",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b7200bf705cdbafad2d62f24554f90a7f317ad9fc4121e9a8a33f36bf1060215",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ee63235/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
