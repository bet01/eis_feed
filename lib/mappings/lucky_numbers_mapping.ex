defmodule EisFeed.Mappings.LuckyNumbersMapping do
  @rule_set_bet_types Application.compile_env!(:eis_feed, :rule_set_bet_types)

  @bet_type_status_id 1
  @bonus_set 1
  @main_set 2
  @both_sets 3

  @set_names %{
    @bonus_set => "Bonus",
    @main_set => "Main Set",
    @both_sets => "Main Set & Bonus"
  }

  def to_bet_types(rule_sets) do
    Enum.group_by(rule_sets, fn rule_set -> rule_set["RuleSetID"] end)
    |> Enum.map(fn {rule_set_id, rule_sets_data} ->
      %{bet_type_id: bet_type_id, bet_type_name: bet_type_name} =
        Map.get(@rule_set_bet_types, rule_set_id)

      %{
        "betTypeId" => bet_type_id,
        "betTypeName" => bet_type_name,
        "betTypeStatusId" => @bet_type_status_id,
        "markets" => to_markets(rule_sets_data)
      }
    end)
  end

  def to_markets(rule_sets_data) do
    Enum.map(rule_sets_data, fn rule_set_data ->
      to_market(rule_set_data)
    end)
  end

  defp to_market(rule_set_data) do
    market_id = get_market_id(rule_set_data)

    %{
      "marketId" => market_id,
      "active" => to_bool(rule_set_data["Enabled"]),
      "marketName" => get_market_name(rule_set_data, market_id),
      "marketOdd" => rule_set_data["Odds"]
    }
  end

  defp get_market_name(%{"RuleSetID" => "1"} = rule_set_data, market_id) do
    balls_num(rule_set_data) <> " (#{@set_names[market_id]})"
  end

  defp get_market_name(%{"RuleSetID" => rule_set_id}, market_id) do
    @set_names[market_id] <> " #{@rule_set_bet_types[rule_set_id][:market_name]}"
  end

  defp get_market_id(%{"MainSet" => "True", "ExtraSet" => "True"}), do: @both_sets
  defp get_market_id(%{"MainSet" => "False", "ExtraSet" => "True"}), do: @bonus_set
  defp get_market_id(%{"MainSet" => "True", "ExtraSet" => "False"}), do: @main_set

  defp balls_num(%{"BallsToPick" => balls_num}) when balls_num > "1", do: "#{balls_num} Balls"
  defp balls_num(%{"BallsToPick" => balls_num}), do: "#{balls_num} Ball"

  defp to_bool("True"), do: true
  defp to_bool(_), do: false
end
