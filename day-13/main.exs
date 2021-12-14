defmodule Helpers do
  def convert_point(command) do
    if command == nil, do: nil, else: %{
      point: [
        String.to_integer(Map.get(command, "x")),
        String.to_integer(Map.get(command, "y"))
      ],
    }
  end
  def convert_fold_x(command) do
    if command == nil, do: nil, else: %{
      fold_x: String.to_integer(Map.get(command, "fold_x")),
    }
  end
  def convert_fold_y(command) do
    if command == nil, do: nil, else: %{
      fold_y: String.to_integer(Map.get(command, "fold_y")),
    }
  end
end

# "6,10
# 0,14
# 9,10
# 0,3
# 10,4
# 4,11
# 6,0
# 6,12
# 4,1
# 0,13
# 10,12
# 3,4
# 3,0
# 8,4
# 1,10
# 2,14
# 8,10
# 9,0

# fold along y=7
# fold along x=5
# "
File.read!("data.txt")
|> String.split("\n")
|> Enum.filter(&(&1 != ""))
|> Enum.map(&(
  Helpers.convert_point(Regex.named_captures(~r/^(?<x>\d+),(?<y>\d+)$/, &1)) ||
  Helpers.convert_fold_x(Regex.named_captures(~r/^fold along x=(?<fold_x>\d+)$/, &1)) ||
  Helpers.convert_fold_y(Regex.named_captures(~r/^fold along y=(?<fold_y>\d+)$/, &1))
))
|> (fn(commands) ->
  points = commands
  |> Enum.filter(&(Map.has_key?(&1, :point)))
  |> Enum.map(&(&1.point))
  # |> Enum.sort(&(
  #   Enum.at(&1, 1) <= Enum.at(&2, 1) &&
  #   (
  #     Enum.at(&1, 1) < Enum.at(&2, 1) ||
  #     Enum.at(&1, 0) <= Enum.at(&2, 0)
  #   )
  # ))

  commands
  |> Enum.filter(&(!Map.has_key?(&1, :point)))
  |> Enum.reduce(points, fn(command, points) ->
    if Map.has_key?(command, :fold_x) do
      points_1 = points
      |> Enum.filter(&(Enum.at(&1, 0) < command.fold_x))

      points_2 = points
      |> Enum.filter(&(Enum.at(&1, 0) > command.fold_x))
      |> Enum.map(&([abs(Enum.at(&1, 0) - 2*command.fold_x), Enum.at(&1, 1)]))
      # |> Enum.reverse()

      Enum.uniq(points_1 ++ points_2)
    else
      points_1 = points
      |> Enum.filter(&(Enum.at(&1, 1) < command.fold_y))

      points_2 = points
      |> Enum.filter(&(Enum.at(&1, 1) > command.fold_y))
      |> Enum.map(&([Enum.at(&1, 0), abs(Enum.at(&1, 1) - 2*command.fold_y)]))
      # |> Enum.reverse()

      Enum.uniq(points_1 ++ points_2)
    end
  end)
end).()
|> Enum.sort(&(
  Enum.at(&1, 1) <= Enum.at(&2, 1) &&
  (
    Enum.at(&1, 1) < Enum.at(&2, 1) ||
    Enum.at(&1, 0) <= Enum.at(&2, 0)
  )
))
|> Enum.group_by(&(Enum.at(&1, 1)), &(Enum.at(&1, 0)))
|> Enum.map(&(elem(&1, 1)))
|> Enum.map(fn(points) ->
  Enum.reduce(points, {"", -1}, fn(x, {line, last_x}) ->
    {line <> String.duplicate(" ", x - last_x - 1) <> "*", x}
  end)
end)
# |> Enum.reduce({0,0,[]}, fn([x, y], {last_x,last_y,lines}) ->
#   lines = lines ++ (if y > last_y, do: Enum.map(0..y - last_y, fn(_) -> ""), else: [])

#   {x,y,lines}
# end)
# |> Enum.count()
|> IO.inspect(charlist: :as_lists)


# 7
# 14 -> 0 = abs(14 - 2*7)
# 13 -> 1 = abs(13 - 2*7)
# 12 -> 2
# 11 -> 3
# 10 -> 4
# 9 -> 5
# 8 -> 6
