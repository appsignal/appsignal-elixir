defmodule Appsignal.Agent do
  def version, do: "aa1bfe4"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "2f594a793727e00e536d0f9dca468e7203ef25a7f759dcf268b1268b1e262717",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "2f594a793727e00e536d0f9dca468e7203ef25a7f759dcf268b1268b1e262717",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "705916391b1184b3acfa758530affdaa481b36f298be3b204400e166102bb31e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "705916391b1184b3acfa758530affdaa481b36f298be3b204400e166102bb31e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "f88c0f8c104cf3105337088d3d074accb60092a0e7063ec0f3c7c10ab17c2d28",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "f88c0f8c104cf3105337088d3d074accb60092a0e7063ec0f3c7c10ab17c2d28",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "f752072ab8fb537dbf737b2a409b05974f878e4b05167be8d27309ec6f5fc4a7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "ea52636f4813aae6c9342b46b063f7bcf39e62e39212ca658c991ade6ff19992",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "71bae7e45d32e09c092c6e85bfa88b2009a54ea72a46200e45b083515f95abbe",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "71bae7e45d32e09c092c6e85bfa88b2009a54ea72a46200e45b083515f95abbe",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa1bfe4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
