# DO NOT EDIT
# This is a file downloaded by the `script/generate_ci_matrix` task.
# Update it in appsignal-elixir, then run script/generate_ci_matrix to
# redownload it.
VERSIONS = {
  "26.0" => {elixir: ["main", "1.15.0", "1.14.5"], phoenix: ["~> 1.7.0"]},
  "25.3" => {elixir: ["main", "1.15.0", "1.14.5", "1.13.4"], phoenix: ["~> 1.7.0"]},
  "24.3" => {elixir: ["main", "1.15.0", "1.14.5", "1.13.4", "1.12.3", "1.11.4"], phoenix: ["~> 1.7.0"]},
  "23.3" => {elixir: ["1.14.5", "1.13.4", "1.12.3", "1.11.4", "1.10.4"], phoenix: ["~> 1.6.0"]},
  "22.3" => {elixir: ["1.13.4", "1.12.3", "1.11.4", "1.10.4", "1.9.4"], phoenix: ["~> 1.6.0"]},
  "21.3" => {elixir: ["1.11.4", "1.10.4", "1.9.4"], phoenix: ["~> 1.6.0"]},
  "20.3" => {elixir: ["1.9.4"], phoenix: ["~> 1.6.0"]}
}
