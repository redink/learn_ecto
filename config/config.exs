use Mix.Config

config :learn_ecto, LearnEcto.Database.Repo,
  log: :debug,
  url: "ecto://postgres:postgres@localhost/learn_ecto_user?pool_size=30"

config :learn_ecto,
  ecto_repos: [LearnEcto.Database.Repo]
