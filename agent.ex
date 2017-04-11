defmodule Appsignal.Agent do
  def version, do: "da14f3b"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "690ae21a087fc9bc8089f492bd2f751c77d9e9573441aa5b2b9427ab8b1e5433",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da14f3b/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "18345e70afdcfc0378503fc6ec48c0949425ad5a650b36a20d721a54c356fe3d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da14f3b/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "18345e70afdcfc0378503fc6ec48c0949425ad5a650b36a20d721a54c356fe3d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da14f3b/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "33dfccb7d422343d3baaed9f2f3d0f70c71162413ab05f4aef59b9cc09acd6b9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da14f3b/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "33dfccb7d422343d3baaed9f2f3d0f70c71162413ab05f4aef59b9cc09acd6b9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da14f3b/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
