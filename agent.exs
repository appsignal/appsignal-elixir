defmodule Appsignal.Agent do
  def version, do: "64deb96"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "1ab49acb93615b0c1e2fe9e48c179e0fd3fcadd391523940c322f154bd479a83",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "1ab49acb93615b0c1e2fe9e48c179e0fd3fcadd391523940c322f154bd479a83",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "a27cf9191f70f13263662f6ca2555cada27ebb4384d6c981a534774b5e7def0e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "a27cf9191f70f13263662f6ca2555cada27ebb4384d6c981a534774b5e7def0e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "80fb5c2f36b7e8efcfc6914bb707688e248dd06c58b174d07e8a931f4bbf97ce",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "80fb5c2f36b7e8efcfc6914bb707688e248dd06c58b174d07e8a931f4bbf97ce",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "83befc3bb521d5e055eb92d5a5a0afca929bce8968ca6d0426fac6aeaec3df24",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "3cb74695955c7bc809320fa966d7290fe3162926c239bb6a845b82ef7aec266e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "7735718e2789c71f1135100ff4fab13cd85cbebe0ba2b87c5b555b30635bdcdc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "7735718e2789c71f1135100ff4fab13cd85cbebe0ba2b87c5b555b30635bdcdc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/64deb96/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
