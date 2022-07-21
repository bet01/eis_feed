defmodule EisFeed.Application do
  use Application

  @impl true
  def start(_type, _args) do
    rabbit_queues = Application.get_env(:eis_feed, :rabbit_queues)

    children = consumers(rabbit_queues)

    opts = [strategy: :one_for_one, name: EisFeed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp consumers(rabbit_queues) do
    Enum.map(rabbit_queues, fn %{queue: queue, sport: sport} ->
      %{
        id: sport,
        start: {EisFeed.Rabbit.Consumer, :start_link, [queue]}
      }
    end)
  end
end
