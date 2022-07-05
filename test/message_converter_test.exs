defmodule EisFeed.MessageConverterTest do
  use ExUnit.Case

  alias EisFeed.MessageConverter

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

    %{"fixtureId" => fixture_id, "producerId" => @prematch} =
      MessageConverter.to_common_format(json, now(), :fixture_change)

    assert fixture_id == json["FixtureData"]["FixtureID"]
  end

  test "can convert EIS greyhound message" do
    json = decode!("greyhound")

    %{"fixtureId" => fixture_id} = MessageConverter.to_common_format(json, now(), :fixture_change)
    assert fixture_id == json["FixtureData"]["FixtureID"]
  end

  test "can convert EIS horse racing message" do
    json = decode!("horse_racing")

    %{"fixtureId" => fixture_id} = MessageConverter.to_common_format(json, now(), :fixture_change)
    assert fixture_id == json["MeetingID"]
  end

  test "can convert EIS lucky numbers message" do
    json = decode!("lucky_numbers")

    %{"fixtureId" => fixture_id} = MessageConverter.to_common_format(json, now(), :fixture_change)
    assert fixture_id == json["DrawID"]
  end

  test "can convert EIS in running message" do
    json = decode!("in_running")

    %{"fixtureId" => fixture_id, "producerId" => @live_in_play} =
      MessageConverter.to_common_format(json, now(), :fixture_change)

    assert fixture_id == json["FixtureData"]["FixtureID"]
  end

  defp now() do
    DateTime.utc_now() |> DateTime.to_unix(:millisecond)
  end
end
