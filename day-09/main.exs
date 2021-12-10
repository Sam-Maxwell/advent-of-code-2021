defmodule Helpers do
  def at(map, rows, columns, row, column) do
    Helpers.at(map, rows, columns, row, column, 0)
  end
  def at(map, rows, columns, row, column, default) do
    if Helpers.on_map(rows, columns, row, column),
      do: Enum.at(Enum.at(map, row), column),
      else: default
  end
  def on_map(rows, columns, row, column) do
    row >= 0 && row < rows && column >= 0 && column < columns
  end
  def basin_size(map, rows, columns, row, column) do
    Helpers.basin_size(map, rows, columns, row, column, [])
  end
  def basin_size(map, rows, columns, row, column, visits) do
    visit = {row, column}
    visited? = Enum.member?(visits, visit)
    visits = if !visited?, do: [visit] ++ visits, else: visits

    if visited? || Helpers.at(map, rows, columns, row, column, 9) == 9 do
      status = if visited?, do: 'visited', else: 'done'
      {0, visits}
    else
      total_size = 1

      {size, visits} = Helpers.basin_size(map, rows, columns, row-1, column, visits)
      total_size = total_size + size

      {size, visits} = Helpers.basin_size(map, rows, columns, row+1, column, visits)
      total_size = total_size + size

      {size, visits} = Helpers.basin_size(map, rows, columns, row, column+1, visits)
      total_size = total_size + size

      {size, visits} = Helpers.basin_size(map, rows, columns, row, column-1, visits)
      total_size = total_size + size

      {total_size, visits}
    end
  end
end

# "2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
# "
File.read!("data.txt")
|> String.split("\n")
|> Enum.map(&String.trim/1)
|> Enum.filter(fn(x) -> x != "" end)
|> Enum.map(fn(row) ->
  String.graphemes(row)
  |> Enum.map(&String.to_integer/1)
end)
|> (fn(heightmap) ->
  rows = Enum.count(heightmap)
  columns = Enum.count(Enum.at(heightmap, 0))
  riskmap = Enum.map(0..rows-1, fn(row) ->
    Enum.map(0..columns-1, fn(column) ->
      center = Helpers.at(heightmap, rows, columns, row, column)
      north = Helpers.at(heightmap, rows, columns, row-1, column, center+1)
      south = Helpers.at(heightmap, rows, columns, row+1, column, center+1)
      east = Helpers.at(heightmap, rows, columns, row, column+1, center+1)
      west = Helpers.at(heightmap, rows, columns, row, column-1, center+1)
      if center < north && center < south && center < east && center < west,
        do: center,
        else: nil
    end)
  end)
  { rows, columns, heightmap, riskmap }
end).()
|> (fn({rows, columns, heightmap, riskmap}) ->
  Enum.map(0..rows-1, fn(row) ->
    Enum.map(0..columns-1, fn(column) ->
      is_low_point? = Enum.at(Enum.at(riskmap, row), column) != nil
      if is_low_point? do
        {size,_} = Helpers.basin_size(heightmap, rows, columns, row, column)
        size
      else
        nil
      end
    end)
  end)
end).()
|> Enum.reduce([], fn(row, columns) -> row ++ columns end)
|> Enum.filter(fn(column) -> column != nil end)
|> Enum.sort()
|> Enum.reverse()
|> (fn(sizes) -> Enum.at(sizes, 0) * Enum.at(sizes, 1) * Enum.at(sizes, 2) end).()
|> IO.inspect(charlist: :as_lists)
