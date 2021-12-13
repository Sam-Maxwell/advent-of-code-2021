defmodule Helpers do
  def add_connections(caves, [from, to]) do
    caves = Map.update(caves, from, [to], fn(connections) -> [to] ++ connections end)
    Map.update(caves, to, [from], fn(connections) -> [from] ++ connections end)
  end
  def explore(caves, name) do
    Helpers.explore(caves, name, [])
  end
  def explore(caves, name, visited) do
    name_and_visited = [name] ++ visited
    if name == "end" do
      name_and_visited
    else
      small_caves_visited = Enum.filter(visited, fn(name) -> Regex.match?(~r/^[a-z]/, name) end)
      small_caves_visited_twice = Enum.reduce(Enum.uniq(small_caves_visited), [], fn(small_cave_visited, small_caves_visited_twice) ->
        visits = Enum.filter(small_caves_visited, fn(cave) -> cave == small_cave_visited end)
        (if Enum.count(visits) >= 2, do: [small_cave_visited], else: []) ++ small_caves_visited_twice
      end)
      to_visit = Map.get(caves, name) -- small_caves_visited_twice
      if Enum.count(to_visit) == 0 do
        []
      else
        Enum.map(to_visit, fn(to_name) -> Helpers.explore(caves, to_name, name_and_visited) end)
      end
    end
  end
end

# "start-A
# start-b
# A-c
# A-b
# b-d
# A-end
# b-end
# "
File.read!("data.txt")
|> String.split("\n")
|> Enum.filter(fn(x) -> x != "" end)
|> Enum.reduce(nil, fn(connection, caves) ->
  caves = if caves == nil, do: %{}, else: caves
  Helpers.add_connections(caves, String.split(connection, "-"))
end)
|> Helpers.explore("start", [])
|> List.flatten()
|> Enum.reduce([[]], fn(name, paths) ->
  paths = if name == "end", do: [[]] ++ paths, else: paths
  [head|tail] = paths
  head = [name] ++ head
  [head] ++ tail
end)
|> Enum.filter(fn(path) -> Enum.count(path) > 0 end)
|> Enum.filter(fn(path) ->
  path
  |> Enum.filter(fn(cave) ->
    Regex.match?(~r/^[a-z]/, cave) &&
      Enum.count(Enum.filter(path, fn(cave2) -> cave2 == cave end)) == 2
  end)
  |> Enum.uniq()
  |> (fn(small_cave_repeats) -> Enum.count(small_cave_repeats) <= 1 && !Enum.member?(small_cave_repeats, "start") end).()
end)
|> Enum.count()
|> IO.inspect(charlists: :as_list)
