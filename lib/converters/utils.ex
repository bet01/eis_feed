defmodule EisFeed.Converters.Utils do
  @live_in_play 1
  @prematch 3
  @zero_timestamp_offset "Z"

  def get_market_status(status) when status in ["Active", "True"], do: true
  def get_market_status(_), do: false

  def get_producer_id(%{"SportsName" => "In-Running"}), do: "#{@live_in_play}"
  def get_producer_id(_), do: "#{@prematch}"

  def to_unix_timestamp(timestamp) do
    {:ok, new_timestamp, _} = DateTime.from_iso8601("#{timestamp}#{@zero_timestamp_offset}")
    DateTime.to_unix(new_timestamp, :millisecond)
  end
end
