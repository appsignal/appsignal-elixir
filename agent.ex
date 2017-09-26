defmodule Appsignal.Agent do
  def version, do: "aa306e5"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "e6bb0fad95403828195f5e186128b6e9389b07c625b3845b52768ab8dd57cbf5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa306e5/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "05d76d816303531b4aa1905f775a0d5b8fea4e3d15b9f3b99105f499c3c549cb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa306e5/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "05d76d816303531b4aa1905f775a0d5b8fea4e3d15b9f3b99105f499c3c549cb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa306e5/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "3f4213164491604a1381b042404967ce11225f2c5193ffa31960552ae6451a34",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa306e5/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "3f4213164491604a1381b042404967ce11225f2c5193ffa31960552ae6451a34",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/aa306e5/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
