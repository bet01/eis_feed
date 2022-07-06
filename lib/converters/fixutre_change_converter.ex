defmodule EisFeed.Converters.FixtureChangeConverter do
  @live_in_play 1
  @prematch 3

  def to_common_format(%{"FixtureData" => fixture_data} = fixture, timestamp) do
    %{
      "source" => "EIS",
      "fixtureId" => fixture_data["FixtureID"],
      "messageType" => "Fixture",
      "category" => %{
        "categoryId" => fixture["CountryID"],
        "categoryName" => fixture["CountryName"]
      },
      "competitors" => to_competitors(fixture_data),
      "created" => timestamp,
      "fixtureName" => fixture_data["FixtureName"],
      "producerId" => get_producer_id(fixture),
      "sport" => %{
        "sportId" => fixture["SportID"],
        "sportName" => fixture["SportsName"]
      },
      "startDate" => fixture_data["FixtureStartDateTime"],
      "status" => fixture_data["FixtureStatus"],
      "tournament" => %{
        "tournamentId" => fixture["TournamentID"],
        "tournamentName" => fixture["TournamentName"]
      },
      "type" => "match"
    }
  end

  def to_common_format(%{"RaceData" => race_data} = race, _timestamp) do
    %{
      "source" => "EIS",
      "fixtureId" => race["MeetingID"],
      "messageType" => "Fixture",
      "category" => %{
        "categoryId" => race["CountryID"],
        "categoryName" => race["CountryName"]
      },
      "competitors" => to_competitors(race_data),
      "created" => race["Timestamp"],
      "fixtureName" => race["MeetingName"],
      "producerId" => @prematch,
      "sport" => %{
        "sportId" => race["SportID"],
        "sportName" => race["SportName"]
      },
      "startDate" => race["MeetingDate"],
      "status" => race_data["RaceStatus"],
      "tournament" => nil,
      "type" => "match"
    }
  end

  def to_common_format(%{"DrawID" => draw_id} = lucky_numbers_data, timestamp) do
    %{
      "source" => "EIS",
      "messageType" => "Fixture",
      "fixtureId" => draw_id,
      "category" => %{
        "categoryId" => lucky_numbers_data["CountryID"],
        "categoryName" => lucky_numbers_data["CountryName"]
      },
      "competitors" => nil,
      "created" => timestamp,
      "fixtureName" => lucky_numbers_data["LotteryShortName"],
      "producerId" => @prematch,
      "sport" => %{
        "sportId" => lucky_numbers_data["SportID"],
        "sportName" => lucky_numbers_data["SportName"]
      },
      "startDate" => lucky_numbers_data["DrawDate"],
      "status" => lucky_numbers_data["LotteryResults"],
      "tournament" => %{
        "tournamentId" => lucky_numbers_data["LotteryID"],
        "tournamentName" => lucky_numbers_data["LotteryName"]
      },
      "type" => "match"
    }
  end

  defp to_competitors(%{"Horses" => %{"HorseData" => horses}}) do
    Enum.map(horses, fn horse ->
      %{
        "id" => horse["HorseID"],
        "name" => horse["HorseName"]
      }
    end)
  end

  defp to_competitors(%{"TeamData" => %{"Team" => teams}}) do
    teams_sorted = Enum.sort_by(teams, fn team -> team["TeamType"] end, :desc)

    Enum.map(teams_sorted, fn team ->
      %{
        "id" => team["TeamID"],
        "name" => team["TeamName"]
      }
    end)
  end

  defp to_competitors(%{"TeamData" => _team_data}) do
    nil
  end

  defp get_producer_id(%{"SportsName" => "In-Running"}), do: @live_in_play
  defp get_producer_id(_), do: @prematch
end
