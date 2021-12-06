#"0,9 -> 5,9
#8,0 -> 0,8
#9,4 -> 3,4
#2,2 -> 2,1
#7,0 -> 7,4
#6,4 -> 2,0
#0,9 -> 2,9
#3,4 -> 1,4
#0,0 -> 8,8
#5,5 -> 8,2"
#|> String.split("\n")
File.stream!("data.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(fn(line) ->
  [_|values] = Regex.run(~r/^(\d+),(\d+) -> (\d+),(\d+)$/,line)
  values|> Enum.map(&String.to_integer/1)
end)
#|> Enum.filter(fn([x1,y1,x2,y2]) ->
#  x1 == x2 || y1 == y2 || abs(x1 - x2) == abs(y1 - y2)
#end)
|> Enum.map(fn([x1,y1,x2,y2]) ->
  # it's easier for my brain if the 2nd point is always in a higher row
  point1 = {x1,y1}
  point2 = {x2,y2}
  if y2 < y1, do: [point2,point1], else: [point1,point2]
end)
|> (fn(lines) ->
  {
    lines,
    Enum.reduce(lines, {0, 0}, fn([{x1, y1}, {x2, y2}], {max_y, max_x}) ->
      {
        max(max_y, max(y1, y2)),
        max(max_x, max(x1, x2))
      }
    end)
  }
end).()
|> (fn({lines, {max_y, max_x}}) ->
  {
    lines,
    Enum.map(0..max_y, fn(_) ->
      Enum.map(0..max_x, fn(_) -> 0 end)
    end)
  }
end).()
|> (fn({lines, matrix}) ->
  matrix = Enum.reduce(lines, matrix, fn([{x1, y1}, {x2, y2}], matrix) ->
    beg_x = min(x1, x2)
    end_x = max(x1, x2)
    beg_y = min(y1, y2)
    end_y = max(y1, y2)
    is_diagonal = x1 != x2 && y1 != y2

    incr = if y2 > y1 && x2 > x1 || y2 < y1 && x2 < x1, do: 1, else: -1

    Enum.with_index(matrix)
    |> Enum.map(fn({row, y}) ->
      Enum.with_index(row)
      |> Enum.map(fn({intersections, x}) ->
        is_in_x_range = x >= beg_x && x <= end_x
        is_in_y_range = y >= beg_y && y <= end_y
        is_on_line = is_in_y_range && is_in_x_range && (!is_diagonal || x == x1 + (y - beg_y)*incr)

        increment = if is_on_line,
          do: 1,
          else: 0
        intersections + increment
      end)
    end)
  end)
  matrix
end).()
|> Enum.reduce(0, fn(row, total) ->
  total + Enum.reduce(row, 0, fn(column, total) ->
    total + if column > 1, do: 1, else: 0
  end)
end)
|> IO.inspect(charlists: :as_lists)
