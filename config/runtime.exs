import Config

config :eis_feed, :rabbit_config,
  host: System.fetch_env!("RABBIT_MQ_HOST"),
  port: System.fetch_env!("RABBIT_MQ_PORT") |> String.to_integer(),
  username: System.fetch_env!("RABBIT_MQ_USERNAME"),
  password: System.fetch_env!("RABBIT_MQ_PASSWORD")

config :eis_feed, :rabbit_queues, [
  %{
    sport: :soccer_greyhound,
    queue: System.fetch_env!("RABBIT_MQ_SOCCER_GREYHOUND_QUEUE")
  },
  %{
    sport: :horse_racing,
    queue: System.fetch_env!("RABBIT_MQ_HORSE_RACING_QUEUE")
  },
  %{
    sport: :lucky_numbers,
    queue: System.fetch_env!("RABBIT_MQ_LOTTO_QUEUE")
  },
  %{
    sport: :in_running,
    queue: System.fetch_env!("RABBIT_MQ_IN_RUNNING_QUEUE")
  }
]
