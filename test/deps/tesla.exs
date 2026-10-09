{server, _binding} = Code.eval_file("test/deps/shared/http_server.exs")

[{:tesla, "~> 1.0"}] ++ server
