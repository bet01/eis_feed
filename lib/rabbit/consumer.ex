defmodule EisFeed.Rabbit.Consumer do
  @moduledoc """
  Consumes and decodes messages from rabbitMQ and
  forwards them to the relevant fixture worker
  """
  use GenServer, restart: :transient
  use AMQP

  alias EisFeed.Converters.{FixtureChangeConverter, OddsChangeConverter}
  require Logger

  def start_link(queue_name) do
    state = %{
      queue_name: queue_name
    }

    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :request_amqp_stream}}
  end

  @impl true
  def handle_continue(:request_amqp_stream, %{queue_name: queue_name} = state) do
    case maybe_connect_and_bind_to_queue(queue_name) do
      {:ok, chan} ->
        Logger.info("Started consumer for #{queue_name}")
        new_state = Map.put(state, :chan, chan)
        {:noreply, new_state}

      {:error, _reason} ->
        {:stop, :shutdown, state}
    end
  end

  @impl true
  def handle_info({:basic_consume_ok, _meta}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_cancel, _meta}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:basic_cancel_ok, _meta}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag, redelivered: _redelivered}},
        %{chan: chan} = state
      ) do
    Logger.info("Received message: #{payload}")
    decoded_payload = Poison.decode!(payload)
    {fixture_change, odds_change} = process_message(decoded_payload)
    Logger.info("Fixture change: #{inspect(fixture_change, pretty: true)}")
    Logger.info("Odds change: #{inspect(odds_change, pretty: true)}")
    Basic.ack(chan, tag)
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.error("Consumer terminating | reason: #{inspect(reason)} | state: #{inspect(state)}")
    :normal
  end

  defp process_message(message) do
    timestamp = now()
    fixture_change = FixtureChangeConverter.to_common_format(message, timestamp)
    odds_change = OddsChangeConverter.to_common_format(message, timestamp)
    {fixture_change, odds_change}
  end

  defp maybe_connect_and_bind_to_queue(queue_name) do
    with {:ok, conn} <- open_connection(),
         {:ok, chan} <- open_channel(conn),
         {:ok, _consumer_tag} <- Basic.consume(chan, queue_name) do
      {:ok, chan}
    else
      {:error, _reason} = error ->
        Logger.error("Failed to connect to rabbit | reason: #{inspect(error)}")
        error
    end
  end

  defp open_connection do
    config = Application.get_env(:eis_feed, :rabbit_config)
    AMQP.Connection.open(config)
  end

  defp open_channel(conn), do: AMQP.Channel.open(conn)

  defp now(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
