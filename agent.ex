defmodule Appsignal.Agent do
  def version, do: "d54a76a"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "281d91b060365e05fc2df94eb88b0b8d7f6fde06c439829bdd170f202f5aa5b1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d54a76a/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "91e9d317a45d0a5e1a03b5a12480c221182b8f460638532181b58b362941d3d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d54a76a/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "91e9d317a45d0a5e1a03b5a12480c221182b8f460638532181b58b362941d3d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d54a76a/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "f9732af3f4913341d0ec70474d893472fd1bf9720c5cea098a24be92379872aa",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d54a76a/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "f9732af3f4913341d0ec70474d893472fd1bf9720c5cea098a24be92379872aa",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d54a76a/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
