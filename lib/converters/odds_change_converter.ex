defmodule EisFeed.Converters.OddsChangeConverter do
  alias EisFeed.Converters.Utils
  alias EisFeed.Mappings.LuckyNumbersMapping

  def to_common_format(
        %{"FixtureData" => %{"BetTypeData" => bet_type_data} = fixture_data} = fixture,
        timestamp
      ) do
    %{
      "fixtureId" => fixture_data["FixtureID"],
      "created" => timestamp |> to_string(),
      "fixtureType" => "match",
      "producerId" => Utils.get_producer_id(fixture),
      "betTypes" => to_bet_types(bet_type_data)
    }
  end

  def to_common_format(%{"RaceData" => _race_data}, _timestamp), do: %{}

  def to_common_format(%{"LotteryRuleSets" => rule_sets} = lottery, timestamp) do
    %{
      "fixtureId" => lottery["LotteryID"],
      "created" => timestamp |> to_string(),
      "fixtureType" => "match",
      "producerId" => Utils.get_producer_id(lottery),
      "betTypes" => to_bet_types(rule_sets)
    }
  end

  defp to_bet_types(%{"BetType" => bet_types}) do
    Enum.map(bet_types, fn %{"Market" => markets} = bet_type ->
      %{
        "betTypeId" => bet_type["BetTypeID"],
        "betTypeName" => bet_type["BetTypeName"],
        "betTypeStatusId" => bet_type["BetTypeStatusID"],
        "markets" => to_markets(markets)
      }
    end)
  end

  defp to_bet_types(%{"RuleSet" => rule_set}) do
    LuckyNumbersMapping.to_bet_types(rule_set)
  end

  defp to_markets(markets) do
    Enum.map(markets, fn market ->
      %{
        "marketId" => market["MarketID"],
        "active" => Utils.get_market_status(market["MarketStatus"]),
        "marketName" => market["MarketName"],
        "marketOdd" => market["MarketOdds"]
      }
    end)
  end
end
