defmodule Appsignal.Agent do
  def version, do: "0ad5573"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "1e0701414c6777116e0c300b424f612fa13eb8e2f86587622e92c3249ca1f7cf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0ad5573/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "6913c60616479c759ed592e9977e4370b10f9992d55e09624c2c59422feadbf3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0ad5573/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "6913c60616479c759ed592e9977e4370b10f9992d55e09624c2c59422feadbf3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0ad5573/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "0a08981be4b864756275d9c780f637571aa1bea957776db1aad30013e5f155f9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0ad5573/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "0a08981be4b864756275d9c780f637571aa1bea957776db1aad30013e5f155f9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0ad5573/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
