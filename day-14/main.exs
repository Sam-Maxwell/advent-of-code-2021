# "NNCB

# CH -> B
# HH -> N
# CB -> H
# NH -> C
# HB -> C
# HC -> B
# HN -> C
# NN -> C
# BH -> H
# NC -> B
# NB -> B
# BN -> B
# BB -> N
# BC -> B
# CC -> N
# CN -> C
# "
File.read!("data.txt")
|> String.split("\n")
|> Enum.filter(&(&1 != ""))
|> (fn([template|rules]) ->
  insertions = Enum.reduce(rules, %{}, fn(rule, rules) ->
    rule = Regex.named_captures(~r/(?<pair>[A-Z]{2}) -> (?<insert>[A-Z])/, rule)
    Map.put(rules, Map.get(rule, "pair"), Map.get(rule, "insert"))
  end)
  Enum.reduce(1..40, template, fn(_, template) ->
    String.graphemes(template)
    |> Enum.chunk_every(2, 1, :discard)
    |> (fn(pairs) ->
      [Enum.at(Enum.at(pairs, 0), 0)]
      ++ Enum.map(pairs, fn(pair) ->
        insert = Map.get(insertions, Enum.join(pair))
        insert <> Enum.at(pair, 1)
      end)
    end).()
    |> Enum.join()
  end)
end).()
|> String.graphemes()
|> Enum.group_by(&(&1), fn(_) -> 1 end)
|> Enum.map(&({elem(&1, 0), Enum.count(elem(&1, 1))}))
|> Enum.sort_by(&(elem(&1, 1)))
|> (fn(occurances) ->
  {_, least} = List.first(occurances)
  {_, greatest} = List.last(occurances)
  greatest - least
end).()
|> IO.inspect(charlist: :as_lists)
