{server, _binding} = Code.eval_file("test/deps/shared/http_server.exs")

[{:httpoison, "~> 3.0"}] ++ server
