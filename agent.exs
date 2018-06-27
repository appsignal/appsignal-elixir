defmodule Appsignal.Agent do
  def version, do: "7226b02"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "90661689e5fbe1b3e5d7900be174c9de4e09a6c67b2fa203d442297933320ad2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "90661689e5fbe1b3e5d7900be174c9de4e09a6c67b2fa203d442297933320ad2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "82702a88c2ebbecf7554b517f3b01dfbeaa060119bd952806b1b01b5db496ac5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "82702a88c2ebbecf7554b517f3b01dfbeaa060119bd952806b1b01b5db496ac5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "a4c5e352b1db80a3d1456dc330350662055872203aaf811853f760b63f6198b6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "a4c5e352b1db80a3d1456dc330350662055872203aaf811853f760b63f6198b6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "7a5807d3d233d8d0032fd9a6ea1fc8cf26ceda18f4860aea960eb6e2ee8ecc82",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "24060f0c7f7807a77746010e3b9239666019c3b1f40593ef850f7ce89080259d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "0580a6982ced25846720b64f617ace8330a9dbc4ed4d9fe3f479c95ea339f35f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "0580a6982ced25846720b64f617ace8330a9dbc4ed4d9fe3f479c95ea339f35f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/7226b02/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
