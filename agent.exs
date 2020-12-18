defmodule Appsignal.Agent do
  def version, do: "e770c84"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "9a0e4bc02ac0454a3e09a60d145c3415c3de166c0fa4717f143fdde8ec48c1be",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "9a0e4bc02ac0454a3e09a60d145c3415c3de166c0fa4717f143fdde8ec48c1be",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "688f8fced411c4631b3076e599dcffa994eb2cede839e4f68226e6cf2a41f4e2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "688f8fced411c4631b3076e599dcffa994eb2cede839e4f68226e6cf2a41f4e2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "c2e990469e990b1368c7f16e7b82adf07d2c08edab7509252029f8277c5512f5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "e6c46db37fa32b3e21460b779b7c8610e10c89b7ae91e68fa82ea6f1f238d44d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "40084655eff662f85201256ebd143fbf4568f437795952dda5ef7e0fa29a62cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "40084655eff662f85201256ebd143fbf4568f437795952dda5ef7e0fa29a62cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e770c84/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
