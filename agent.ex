defmodule Appsignal.Agent do
  def version, do: "557cdf6"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "ebf3da9dfd753596295db62af5e786cc2d39fd75d23bf2b3b986763e853db87a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/557cdf6/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "853c7d58b6c84f702351cf5690c606b8d51ab686494f989133dde42171ea691e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/557cdf6/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "853c7d58b6c84f702351cf5690c606b8d51ab686494f989133dde42171ea691e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/557cdf6/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "80815cf70a783cf0bcef586361fcbd4460b379ac4876cb824388345cd1cbecbb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/557cdf6/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "80815cf70a783cf0bcef586361fcbd4460b379ac4876cb824388345cd1cbecbb",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/557cdf6/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
