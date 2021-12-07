#"16,1,2,0,4,2,7,1,2,14"
File.read!("data.txt")
|> String.split(",")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> (fn(positions) ->
  max_position = Enum.reduce(positions, 0, &max/2)
  Enum.map(0..max_position, fn(target) ->
    {
      target,
      Enum.reduce(positions, 0, fn(position, count) ->
        if target == position,
          do: count + 1,
          else: count
      end)
    }
  end)
end).()
|> (fn(ats) ->
  Enum.map(ats, fn({target, _}) ->
    {
      target,
      Enum.reduce(ats, 0, fn({position, count}, fuel) ->
        fuel + if position == target,
          do: 0,
          else: Enum.reduce(1..abs(target - position), 0, fn(curr, acc) -> curr + acc end) * count
      end)
    }
  end)
end).()
|> Enum.sort_by(&(elem(&1, 1)))
|> Enum.at(0)
|> elem(1)
|> IO.inspect(charlist: :as_lists)
