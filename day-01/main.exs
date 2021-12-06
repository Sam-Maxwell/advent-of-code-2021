window_size = 3

#["199\n", "200\n", "208\n", "210\n", "200\n", "207\n", "240\n", "269\n", "260\n", "263\n"]
File.stream!("data.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> Enum.chunk_every(window_size, 1, :discard)
|> Enum.chunk_every(2, 1, :discard)
|> Enum.filter(fn([first, second]) -> Enum.sum(second) > Enum.sum(first) end)
|> Enum.count
|> IO.inspect(charlists: :as_lists)