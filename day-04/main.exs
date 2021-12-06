defmodule Helpers do
  def loser?(board) do
    !Helpers.winner?(board)
  end

  def winner?(board) do
    Enum.any?(board, fn(row) -> Enum.all?(row, fn([_, marked]) -> marked end) end)
    || Enum.reduce(0..4, false, fn(column, all_marked) ->
      all_marked || Enum.all?(board, fn(row) -> Enum.at(Enum.at(row, column), 1) end)
    end)
  end
end

File.stream!("data.txt")
#"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
#
#22 13 17 11  0
# 8  2 23  4 24
#21  9 14 16  7
# 6 10  3 18  5
# 1 12 20 15 19
#
# 3 15  0  2 22
# 9 18 13 17  5
#19  8  7 25 23
#20 11 10 24  4
#14 21 16 12  6
#
#14 21 17 24  4
#10 16 15  9 19
#18  8 23 26 20
#22 11 13  6  5
# 2  0 12  3  7"
#|> String.split("\n")
|> Enum.map(&String.trim/1)
|> Enum.reduce({nil,[[],[]]}, fn(line, {draws, boards}) ->
  [head|tail] = boards

  boards = if line == "",
      do: [[]|boards],
      else: if draws == nil,
        do: boards,
        else: [[
          String.split(line, " ")
          |> Enum.map(&String.trim/1)
          |> Enum.filter(fn(value) -> value != "" end)
          |> Enum.map(&String.to_integer/1)
          |> Enum.map(fn(value) -> [value, false] end)|head]|tail]

  draws = if draws == nil,
    do: String.split(line, ",") |> Enum.map(&String.to_integer/1),
    else: draws

  {
    draws,
    boards
  }
end)
|> (fn({draws, boards}) -> {draws, Enum.reverse(boards)} end).()
|> (fn({draws, boards}) -> {draws, Enum.filter(boards, fn(board) -> length(board) > 0 end)} end).()
|> (fn({draws, boards}) -> {draws, Enum.map(boards, fn(board) -> Enum.reverse(board) end)} end).()
|> (fn({draws, boards}) -> {
  draws,
  Enum.reduce_while(draws, {boards, nil, nil}, fn(draw, {boards, _, _}) ->
    boards = boards
    |> Enum.map(fn(board) ->
      Enum.map(board, fn(row) ->
        Enum.map(row, fn([value, marked]) ->
          marked = if value == draw, do: true, else: marked
          [value, marked]
        end)
      end)
    end)

    head = Enum.at(boards, 0)
    if length(boards) == 1 && Helpers.winner?(head),
      do: {:halt, {boards, head, draw}},
      else: {:cont, {Enum.filter(boards, &Helpers.loser?/1), nil, nil}}
  end)
} end).()
|> IO.inspect(charlists: :as_lists)
|> (fn({_,{_,last_winning_board,draw}})->
  Enum.reduce(last_winning_board, 0, fn(row, total) ->
    total + Enum.reduce(row, 0, fn([value, marked], total) ->
      increment = if marked,
        do: 0,
        else: value
      total + increment
    end)
  end) * draw
end).()
|> IO.inspect(charlists: :as_lists)