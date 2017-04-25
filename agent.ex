defmodule Appsignal.Agent do
  def version, do: "f16607c"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "0479e8b0aeba95360e9fd8cfd7e7f7f4c1a8dfc555f6149c0c35d27593a05193",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f16607c/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "3c3c63f26bec0304649cad4fb69410dd6b13313a178f3db7cdeba72b24834715",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f16607c/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "3c3c63f26bec0304649cad4fb69410dd6b13313a178f3db7cdeba72b24834715",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f16607c/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "853398d93cda5f16edd2a931346f97fedea4c16f729bb987564cfbc29e73ef33",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f16607c/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "853398d93cda5f16edd2a931346f97fedea4c16f729bb987564cfbc29e73ef33",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f16607c/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
