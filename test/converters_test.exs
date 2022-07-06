defmodule EisFeed.ConvertersTest do
  use ExUnit.Case

  alias EisFeed.Converters.FixtureChangeConverter
  alias EisFeed.Converters.OddsChangeConverter

  @live_in_play 1
  @prematch 3

  def decode!(path) do
    "test/messages"
    |> Path.join(path <> ".json")
    |> File.read!()
    |> Poison.decode!()
  end

  test "can convert EIS soccer message" do
    json = decode!("soccer")

    assert %{"fixtureId" => fixture_id, "producerId" => @prematch} =
             FixtureChangeConverter.to_common_format(json, now())

    assert fixture_id == json["FixtureData"]["FixtureID"]

    assert %{"fixtureId" => _, "betTypes" => _} =
             OddsChangeConverter.to_common_format(json, now())
  end

  test "can convert EIS greyhound message" do
    json = decode!("greyhound")

    assert %{"fixtureId" => fixture_id} = FixtureChangeConverter.to_common_format(json, now())

    assert fixture_id == json["FixtureData"]["FixtureID"]

    assert %{"fixtureId" => _, "betTypes" => _} =
             OddsChangeConverter.to_common_format(json, now())
  end

  test "can convert EIS horse racing message" do
    json = decode!("horse_racing")

    assert %{"fixtureId" => fixture_id} = FixtureChangeConverter.to_common_format(json, now())

    assert fixture_id == json["MeetingID"]
  end

  test "can convert EIS lucky numbers message" do
    json = decode!("lucky_numbers")

    assert %{"fixtureId" => fixture_id} = FixtureChangeConverter.to_common_format(json, now())

    assert fixture_id == json["DrawID"]

    assert %{"fixtureId" => _, "betTypes" => _} =
             OddsChangeConverter.to_common_format(json, now())
  end

  test "can convert EIS in running message" do
    json = decode!("in_running")

    assert %{"fixtureId" => fixture_id, "producerId" => @live_in_play} =
             FixtureChangeConverter.to_common_format(json, now())

    assert fixture_id == json["FixtureData"]["FixtureID"]

    assert %{"fixtureId" => _, "betTypes" => _} =
             OddsChangeConverter.to_common_format(json, now())
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
