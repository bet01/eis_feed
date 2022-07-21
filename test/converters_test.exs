defmodule EisFeed.ConvertersTest do
  use ExUnit.Case

  alias EisFeed.Converters.FixtureChangeConverter
  alias EisFeed.Converters.OddsChangeConverter
  alias BetMessages.Messages.{FixtureChange, OddsChange}

  @now DateTime.utc_now() |> DateTime.to_unix(:millisecond)

  def decode!(path) do
    "test/messages"
    |> Path.join(path <> ".json")
    |> File.read!()
    |> Poison.decode!()
  end

  test "can convert EIS soccer message" do
    json = decode!("soccer")
    assert_to_common_format(json)
  end

  test "can convert EIS greyhound message" do
    json = decode!("greyhound")
    assert_to_common_format(json)
  end

  test "can convert EIS horse racing message" do
    json = decode!("horse_racing")
    assert_to_common_format(json)
  end

  test "can convert EIS lucky numbers message" do
    json = decode!("lucky_numbers")
    assert_to_common_format(json)
  end

  test "can convert EIS in running message" do
    json = decode!("in_running")
    assert_to_common_format(json)
  end

  defp assert_to_common_format(json) do
    assert common_fixture_change =
             %{"fixtureId" => fixture_id, "fixtureName" => fixture_name} =
             FixtureChangeConverter.to_common_format(json, @now)

    assert %FixtureChange{fixture_id: ^fixture_id, name: ^fixture_name} =
             FixtureChange.new!(common_fixture_change)

    assert common_odds_change =
             %{"fixtureId" => fixture_id, "producerId" => producer_id} =
             OddsChangeConverter.to_common_format(json, @now)

    assert %OddsChange{fixture_id: ^fixture_id, producer_id: ^producer_id} =
             OddsChange.new!(common_odds_change)
  end
end
