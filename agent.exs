defmodule Appsignal.Agent do
  def version, do: "96b684b"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "6278d03abdcacde207e210374601b0a98eabace8cbc9fb74dffea3c18fc8a252",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "6278d03abdcacde207e210374601b0a98eabace8cbc9fb74dffea3c18fc8a252",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f3e79a575241a50d7968fe4743c4f4e5aebb840e0b8664d055383caf696d5d38",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f3e79a575241a50d7968fe4743c4f4e5aebb840e0b8664d055383caf696d5d38",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "07ab5749b532f1cc6cb45a3334fd950f6d15edacbe6d1bfe25af75b24df73cd1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "07ab5749b532f1cc6cb45a3334fd950f6d15edacbe6d1bfe25af75b24df73cd1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d0e8f48973bca7d783d654404617bb5ab4f47756deb6805c4876bfcda83981cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "2e3db648d0883f2a7e72f1207ec0976b97d144cafe0a3e755df2d91ca93d113f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8dc226834ef39bac43dbc4a5c6a812c50c34669b0607036dd9494ac587e72d6a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8dc226834ef39bac43dbc4a5c6a812c50c34669b0607036dd9494ac587e72d6a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/96b684b/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
