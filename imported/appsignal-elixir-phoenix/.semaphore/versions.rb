# DO NOT EDIT
# This is a file downloaded by the `script/generate_ci_matrix` task.
# Update it in appsignal-elixir, then run script/generate_ci_matrix to
# redownload it.
VERSIONS = {
  "25.2" => {elixir: ["1.14.3", "1.13.4"], phoenix: ["~> 1.7.0"]},
  "24.3" => {elixir: ["1.14.3", "1.13.3", "1.12.3", "1.11.4"], phoenix: ["~> 1.7.0"]},
  "23.3" => {elixir: ["1.14.3", "1.13.3", "1.12.3", "1.11.4", "1.10.4"], phoenix: ["~> 1.6.0"]},
  "22.3" => {elixir: ["1.13.3", "1.12.3", "1.11.4", "1.10.4", "1.9.4"], phoenix: ["~> 1.6.0"]},
  "21.3" => {elixir: ["1.11.4", "1.10.4", "1.9.4"], phoenix: ["~> 1.6.0"]},
  "20.3" => {elixir: ["1.9.4"], phoenix: ["~> 1.6.0"]}
}
