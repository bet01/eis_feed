import Config

config :eis_feed, :rule_set_bet_types, %{
  "1" => %{
    bet_type_id: "11",
    bet_type_name: "X Balls",
    market_name: "Ball"
  },
  "2" => %{
    bet_type_id: "13",
    bet_type_name: "Drawn",
    # Unsupported needs clarification
    market_name: "Ball Drawn"
  },
  "3" => %{
    bet_type_id: "29",
    bet_type_name: "Odd",
    market_name: "Ball Odd"
  },
  "4" => %{
    bet_type_id: "32",
    bet_type_name: "Sum",
    # Needs clarification
    market_name: "Ball Sum"
  },
  "6" => %{
    bet_type_id: "14",
    bet_type_name: "Single Digit",
    market_name: "Ball Single"
  },
  "8" => %{
    bet_type_id: "29",
    bet_type_name: "Even",
    market_name: "Ball Even"
  },
  "9" => %{
    bet_type_id: "12",
    bet_type_name: "High Number",
    market_name: "Ball High"
  },
  "10" => %{
    bet_type_id: "12",
    bet_type_name: "Low Number",
    market_name: "Ball Low"
  },
  "11" => %{
    bet_type_id: "48",
    # Needs clarification
    bet_type_name: "Powerball",
    market_name: "Ball"
  }
}
