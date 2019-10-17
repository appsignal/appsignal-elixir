defmodule Appsignal.Agent do
  def version, do: "f6353b4"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "53865697d5045f82eaed6fe15289474ec42b6c5fb45ffdb5a73ebbfaf13470e3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "53865697d5045f82eaed6fe15289474ec42b6c5fb45ffdb5a73ebbfaf13470e3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "74c910cf90caaac59333d1ab1e9168c2d902fdfa32cf5bcd3e556350c4065519",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "74c910cf90caaac59333d1ab1e9168c2d902fdfa32cf5bcd3e556350c4065519",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "9a19d33d4d752928ad23699fa09885f7d28599347afec53d7c297807abbff748",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "9a19d33d4d752928ad23699fa09885f7d28599347afec53d7c297807abbff748",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "776b03cf465edd355d5babbe9277e6975bad15937a67cf3fb133f93a825e7d5a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "00432083a2366b10d86ad225d804add5d1a1a8669e4b750e5a767e5c51d11036",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "596794281ee1fdda4325c747cc29526596905ad871980df8fb55b40243fb0e49",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "596794281ee1fdda4325c747cc29526596905ad871980df8fb55b40243fb0e49",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f6353b4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
