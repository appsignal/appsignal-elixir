defmodule Appsignal.Agent do
  def version, do: "16ee990"

  def triples do
    %{
      "x86_64-darwin" => %{

        checksum: "bc1daf4d3ddacd7fd3e5d9c085dbd3649abab4d995b1d83d3683b8d4b1e46474",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "bc1daf4d3ddacd7fd3e5d9c085dbd3649abab4d995b1d83d3683b8d4b1e46474",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "e6b96fa2c0cbe46f4de2ed87a28b9def1164ecad26234dbd4729a68b7aeb7da4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "e6b96fa2c0cbe46f4de2ed87a28b9def1164ecad26234dbd4729a68b7aeb7da4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "f66a385f6ec6621688b7ce624d03a3490defbe4a078fb283813c159d37bed9c7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "f66a385f6ec6621688b7ce624d03a3490defbe4a078fb283813c159d37bed9c7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "dc2d1d1f714b96bba99df6ec2d10b2ca304b3038c0f1c07f7dde4d520c4ba1d4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "1c4a027f53b3b2534772cddd2579105c7bf663e4a57c572a3b34f69a5f0129bb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "78d6505ef0aaddb6559df961e08e03a6030ca160cfc74151aba823ea490d3541",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "78d6505ef0aaddb6559df961e08e03a6030ca160cfc74151aba823ea490d3541",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/16ee990/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
