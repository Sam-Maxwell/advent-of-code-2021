defmodule Helpers do
  def parse(chunk) do
    chunk
    |> String.graphemes()
    |> Enum.reduce_while([], fn(grapheme, stack) ->
      if Enum.member?(["(", "[", "{", "<"], grapheme) do
        {:cont, [grapheme] ++ stack}
      else
        [popped|rest] = stack

        valid? = popped == "(" && grapheme == ")" ||
          popped == "[" && grapheme == "]" ||
          popped == "{" && grapheme == "}" ||
          popped == "<" && grapheme == ">"

        if valid? do
          {:cont, rest}
        else
          score = Map.get(%{ ")": 3, "]": 57, "}": 1197, ">": 25137 }, String.to_existing_atom(grapheme))
          {:halt, score}
        end
      end
    end)
  end
end

# "[({(<(())[]>[[{[]{<()<>>
# [(()[<>])]({[<{<<[]>>(
# {([(<{}[<>[]}>{[]{[(<()>
# (((({<>}<{<{<>}{[]{[]{}
# [[<[([]))<([[{}[[()]]]
# [{[{({}]{}}([{[{{{}}([]
# {<[[]]>}<{[{[{[]{()[[[]
# [<(<(<(<{}))><([]([]()
# <{([([[(<>()){}]>(<<{{
# <{([{{}}[<[[[<>{}]]]>[]]
# "
File.read!("data.txt")
|> String.split("\n")
|> Enum.filter(fn(x) -> x != nil end)
|> Enum.map(&Helpers.parse/1)
|> Enum.filter(fn(x) -> !is_integer(x) end)
|> Enum.map(fn(stack) ->
  Enum.reduce(stack, 0, fn(grapheme, score) ->
    score * 5 + Map.get(%{ "[": 2, "(": 1, "{": 3, "<": 4 }, String.to_existing_atom(grapheme))
  end)
end)
|> Enum.filter(fn(x) -> x > 0 end)
|> Enum.sort()
|> (fn(scores) -> Enum.at(scores, trunc(Enum.count(scores)/2)) end).()
|> IO.inspect(charlist: :as_lists)
