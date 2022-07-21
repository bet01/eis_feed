defmodule EisFeed.Converters.FixtureChangeConverter do
  alias EisFeed.Converters.Utils

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
      "created" => timestamp |> to_string(),
      "fixtureName" => fixture_data["FixtureName"],
      "producerId" => Utils.get_producer_id(fixture),
      "sport" => %{
        "sportId" => fixture["SportID"],
        "sportName" => fixture["SportsName"]
      },
      "startDate" => fixture_data["FixtureStartDateTime"],
      "status" => %{status: fixture_data["FixtureStatus"]} |> Poison.encode!(),
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
      "fixtureId" => race_data["RaceID"],
      "messageType" => "Fixture",
      "category" => %{
        "categoryId" => race["CountryID"],
        "categoryName" => race["CountryName"]
      },
      "competitors" => to_competitors(race_data),
      "created" => Utils.to_unix_timestamp(race["Timestamp"]) |> to_string(),
      "fixtureName" => race_data["RaceNumber"],
      "producerId" => Utils.get_producer_id(race),
      "sport" => %{
        "sportId" => race["SportID"],
        "sportName" => race["SportName"]
      },
      "startDate" => race["MeetingDate"],
      "status" => %{status: race_data["RaceStatus"]} |> Poison.encode!(),
      "tournament" => %{
        "tournamentId" => race["MeetingID"],
        "tournamentName" => race["MeetingName"]
      },
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
      "competitors" => [],
      "created" => timestamp |> to_string(),
      "fixtureName" => lucky_numbers_data["LotteryShortName"],
      "producerId" => Utils.get_producer_id(lucky_numbers_data),
      "sport" => %{
        "sportId" => lucky_numbers_data["SportID"],
        "sportName" => lucky_numbers_data["SportName"]
      },
      "startDate" => lucky_numbers_data["DrawDate"],
      "status" => lucky_numbers_data["LotteryResults"] |> Poison.encode!(),
      "tournament" => %{
        "tournamentId" => lucky_numbers_data["LotteryID"],
        "tournamentName" => lucky_numbers_data["LotteryName"]
      },
      "type" => "match"
    }
  end

  defp to_competitors(%{"Horses" => %{"HorseData" => horses}}) do
    Enum.map(horses, fn horse ->
      horse_id = String.to_integer(horse["HorseID"])

      %{
        "id" => %{"id" => horse_id} |> Poison.encode!(),
        "name" => horse["HorseName"]
      }
    end)
  end

  defp to_competitors(%{"TeamData" => %{"Team" => teams}}) do
    teams_sorted = Enum.sort_by(teams, fn team -> team["TeamType"] end, :desc)

    Enum.map(teams_sorted, fn team ->
      team_id = String.to_integer(team["TeamID"])

      %{
        "id" => %{"id" => team_id} |> Poison.encode!(),
        "name" => team["TeamName"]
      }
    end)
  end

  defp to_competitors(%{"TeamData" => _team_data}) do
    []
  end
end
