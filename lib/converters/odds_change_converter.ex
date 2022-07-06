defmodule EisFeed.Converters.OddsChangeConverter do
  @live_in_play 1
  @prematch 3

  def to_common_format(
        %{"FixtureData" => %{"BetTypeData" => bet_type_data} = fixture_data} = fixture,
        timestamp
      ) do
    %{
      "fixtureId" => fixture_data["FixtureID"],
      "created" => timestamp,
      "fixtureType" => "match",
      "producerId" => get_producer_id(fixture),
      "betTypes" => to_bet_types(bet_type_data)
    }
  end

  def to_common_format(%{"LotteryRuleSets" => rule_set} = lottery, timestamp) do
    %{
      "fixtureId" => lottery["LotteryID"],
      "created" => timestamp,
      "fixtureType" => "match",
      "producerId" => @prematch,
      "betTypes" => to_bet_types(rule_set)
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

  defp to_bet_types(rule_set) do
    %{
      "betTypeId" => nil,
      "betTypeName" => "Lottery",
      "betTypeStatusId" => nil,
      "markets" => to_markets(rule_set)
    }
  end

  defp to_markets(%{"RuleSet" => rule_set}) do
    Enum.map(rule_set, fn rule ->
      %{
        "marketId" => rule["RuleSetID"],
        "active" => get_market_status(rule["Enabled"]),
        "marketName" => rule["RuleSetName"],
        "marketOdd" => rule["Odds"]
      }
    end)
  end

  defp to_markets(markets) do
    Enum.map(markets, fn market ->
      %{
        "marketId" => market["MarketID"],
        "active" => get_market_status(market["MarketStatus"]),
        "marketName" => market["MarketName"],
        "marketOdd" => market["MarketOdds"]
      }
    end)
  end

  defp get_market_status(status) when status in ["Active", "True"], do: true
  defp get_market_status(_), do: false

  defp get_producer_id(%{"SportsName" => "In-Running"}), do: @live_in_play
  defp get_producer_id(_), do: @prematch
end
