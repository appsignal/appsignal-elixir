defmodule Appsignal.Agent do
  def version, do: "5b16a75"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "643cb9d7d8ecc6a994fb8c3455784abe4289f2385fd02a596b94c52fbb2f3f94",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "643cb9d7d8ecc6a994fb8c3455784abe4289f2385fd02a596b94c52fbb2f3f94",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f81ca1d2c43862708ed48de6c492fb8a7ae979024663973b6b47d75abb12ef9c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f81ca1d2c43862708ed48de6c492fb8a7ae979024663973b6b47d75abb12ef9c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "b9d43a7c57338c9e6e1aa85a947685ade910c570bd9035b477bc2b28efecf778",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c1964b137b891c184dfdb5b9cf867a3a849452c4012458973fe9522b5b4432b6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5bfd91805896dc7414a69ba0fc69c6121ba9aef60e8199370221595bee975a78",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5bfd91805896dc7414a69ba0fc69c6121ba9aef60e8199370221595bee975a78",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5b16a75/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
