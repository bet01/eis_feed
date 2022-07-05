defmodule EisFeed.RabbitMQ.Consumer do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    config = Application.get_env(:eis_feed, __MODULE__)

    Broadway.start_link(__MODULE__,
      name: MyBroadway,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: config[:queue],
           connection: [
             username: config[:username],
             password: config[:password],
             host: config[:host]
           ],
           qos: [
             prefetch_count: 50
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 50
        ]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 1500,
          concurrency: 5
        ]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    IO.inspect(message.data, limit: :infinity)
  end
end
