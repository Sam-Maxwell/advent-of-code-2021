days = 256

IO.stream(:stdio, :line)
|> Stream.map(&String.trim/1)
|> Stream.map(&String.split(&1, ","))
|> Enum.at(0)
|> Enum.map(&String.to_integer/1)
|> (fn(ages) ->
  Enum.map(0..8, fn(days) ->
    Enum.reduce(ages, 0, fn(age, total) ->
      total + if age == days,
        do: 1,
        else: 0
    end)
  end)
end).()
# |> (fn(ages) ->
#  IO.inspect({'Initial state:', ages}, charlist: :as_lists)
#  ages
# end).()
|> (fn(ages) ->
  Enum.reduce(1..days, ages, fn(_, [d0, d1, d2, d3, d4, d5, d6, d7, d8]) ->
    ages = [d1, d2, d3, d4, d5, d6, d0 + d7, d8, d0]
    # IO.inspect({'After #{day} days:', ages}, charlist: :as_lists)
    ages
  end)
end).()
# |> IO.inspect(charlist: :as_lists)
|> Enum.reduce(0, fn(count, total) -> total + count end)
|> IO.inspect(charlist: :as_lists)
