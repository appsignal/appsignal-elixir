defmodule Appsignal.Agent do
  def version, do: "4d113e7"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "fe33206c74cc5ee85b0abb31aeda7f10033222ecfa8280a4a3acfea0c84cb991",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "fe33206c74cc5ee85b0abb31aeda7f10033222ecfa8280a4a3acfea0c84cb991",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "b0279e1e642b332af74090e863fbfa2dcc97a00d047b29327c2993fdcc82d136",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "b0279e1e642b332af74090e863fbfa2dcc97a00d047b29327c2993fdcc82d136",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "73d66df13a9b3f0cd891a84d046364eba920e1c1b5e8189f44dbb03a0ba12087",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "73d66df13a9b3f0cd891a84d046364eba920e1c1b5e8189f44dbb03a0ba12087",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "34f5d1c578c9b5273bea0aa96d28d55f3b8be4ed51fcd3697f174fec2249e550",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "778a25822cf53a95c5ee7676c0b2960d7391741789e45117e75b14bcfa566861",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c22d8304951f54504cc2c4a8fed042a3ff2c808c7f9edcf0212ce192df44a7aa",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c22d8304951f54504cc2c4a8fed042a3ff2c808c7f9edcf0212ce192df44a7aa",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4d113e7/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
