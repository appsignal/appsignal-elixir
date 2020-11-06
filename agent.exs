defmodule Appsignal.Agent do
  def version, do: "881e3b3"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "57bf0fed677bf02b445ceca6a92ab97f8b55ea648cd395d3423a98fa05523cbf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "57bf0fed677bf02b445ceca6a92ab97f8b55ea648cd395d3423a98fa05523cbf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "fd3fd8eb14e033c914b36fd008775db279fc09499937f1bce4a4a2a6e8bc192c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "fd3fd8eb14e033c914b36fd008775db279fc09499937f1bce4a4a2a6e8bc192c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "cca80d7b3ab0ba1450618b039f2e5522341e553b3f2852184d04c0f62f1e0ad7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "47a204d30c10ebfdcdff5574ed8401d75ead4c935b504645d7a311731f417b24",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "78ccc748ff600072e99211eb21fa161c15f18ba51217a878957559da2cc86201",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "78ccc748ff600072e99211eb21fa161c15f18ba51217a878957559da2cc86201",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/881e3b3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
