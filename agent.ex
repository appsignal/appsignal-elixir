defmodule Appsignal.Agent do
  def version, do: "da45785"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "4d6a55ec254d8279ee4038886335c539c0cf72b16406da65846e7554aec1dc29",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da45785/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "d8d44663571f5a3e813d36760ded7e6b02c9232545d264e4186e9919959e0bd0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da45785/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "d8d44663571f5a3e813d36760ded7e6b02c9232545d264e4186e9919959e0bd0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da45785/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "ba0cc0e94e85fe7d7d6925b73e60fcfbbbc00d89d1f459fe5274e381b38b005a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da45785/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "ba0cc0e94e85fe7d7d6925b73e60fcfbbbc00d89d1f459fe5274e381b38b005a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/da45785/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
