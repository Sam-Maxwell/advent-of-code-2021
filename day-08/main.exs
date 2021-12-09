signals = ["a","b","c","d","e","f","g"]
digits = [
  [0, "abcefg"],
  [1, "cf"],
  [2, "acdeg"],
  [3, "acdfg"],
  [4, "bcdf"],
  [5, "abdfg"],
  [6, "abdefg"],
  [7, "acf"],
  [8, "abcdefg"],
  [9, "abcdfg"]
]
count_translates = [
  [4, "e"],
  [6, "b"],
  [9, "f"]
]

# "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
# edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
# fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
# fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
# aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
# fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
# dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
# bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
# egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
# gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
# "
#|> String.split("\n")
File.stream!("data.txt")
|> Enum.map(&String.trim/1)
|> Enum.filter(fn(x) -> x != "" end)
|> Enum.map(fn(line) ->
  line
  |> String.split(" | ")
  |> Enum.map(&String.split(&1, " "))
end)
|> Enum.map(fn([input, output]) ->
  counts = Enum.map(signals, fn(signal) ->
    [
      signal,
      Enum.reduce(input, 0, fn(digit, total) ->
        total + if String.contains?(digit, signal),
          do: 1,
        else: 0
      end)
    ]
  end)

  IO.inspect(counts, charlist: :as_lists)

  translates = Enum.map(count_translates, fn([count, output_signal]) ->
    [[input_signal, _]] = Enum.filter(counts, fn([_, input_count]) ->
      input_count == count
    end)
    [input_signal, output_signal]
  end)

  [[f,_]] = Enum.filter(translates, fn([_, signal]) -> signal == "f" end)

  width_2_signals = String.graphemes(Enum.find(input, fn(digit) -> String.length(digit) == 2 end))

  [c] = Enum.filter(width_2_signals, fn(signal) -> signal != f end)

  translates = translates ++ [[c, "c"]]

  width_3_signals = String.graphemes(Enum.find(input, fn(digit) -> String.length(digit) == 3 end))
  [a] = Enum.filter(width_3_signals, fn(signal) -> !Enum.member?([c,f], signal) end)

  translates = translates ++ [[a, "a"]]

  [[b,_]] = Enum.filter(translates, fn([_, signal]) -> signal == "b" end)

  width_4_signals = String.graphemes(Enum.find(input, fn(digit) -> String.length(digit) == 4 end))
  [d] = Enum.filter(width_4_signals, fn(signal) -> !Enum.member?([b,c,f], signal) end)

  translates = translates ++ [[d, "d"]]

  translated = Enum.map(translates, &Enum.at(&1, 0))
  IO.inspect(["translated", translated], charlist: :as_lists)
  [g] = Enum.filter(signals, fn(signal) -> !Enum.member?(translated, signal) end)

  translates = translates ++ [[g, "g"]]

  IO.inspect(input, charlist: :as_lists)
  IO.inspect(output, charlist: :as_lists)
  IO.inspect(translates, charlist: :as_lists)

  Enum.map(output, fn(digit) ->
    String.graphemes(digit)
    |> Enum.map(fn(d) ->
      Enum.filter(translates, fn([from, _]) ->
        from == d
      end)
      |> Enum.at(0)
      |> Enum.at(1)
    end)
    |> Enum.sort()
    |> Enum.join()
    |> (fn(output_digit) ->
      found_digit = Enum.find(digits, fn([_, digit]) ->
        output_digit == digit
      end)
      IO.inspect(output_digit, charlist: :as_lists)
      IO.inspect(found_digit, charlist: :as_lists)
      found_digit
    end).()
    |> Enum.at(0)
  end)
  |> Enum.join()
  |> String.to_integer()
end)
|> Enum.reduce(0, fn(num, total) -> total + num end)
|> IO.inspect(charlist: :as_lists)
# |> Enum.map(fn(output) ->
#   Enum.map(output, fn(digit) ->
#     digit = String.split(digit, "")
#       |> Enum.sort()
#       |> Enum.join("")
#     IO.inspect(digit, charlist: :as_lists)
#     digit
#   end)
#   # Enum.map(output, fn(digit) -> Enum.sort(String.split(digit)) end)
#   output
# end)
# |> Enum.reduce(0, fn(outputs, total) ->
#   total + Enum.reduce(outputs, 0, fn(output, total) ->
#     total + if String.length(output) in [2, 4, 3, 7], do: 1, else: 0
#   end)
# end)
# |> IO.inspect(charlist: :as_lists)

# 1 ->     c,    f,   2 (only 2, yields c)
# 7 -> a,  c,    f,   3 (only 3, yields a)

# 0 -> a,b,c,  e,f,   5 (only 5 without g, yields g)
# 3 -> a,  c,d,  f,g, 5 (only remaining 5 with a,c,f,g, yields d)
# 5 -> a,b,  d,  f,g, 5 (only remaining 5, yields b)
# 4 ->   b,c,d,  f,   4 no new information
# 2 -> a,  c,d,e,  g, 6 (only any without f, yields f)
# 9 -> a,b,c,d,  f,g, 6
# 6 -> a,b,  d,e,f,g, 6
# 8 -> a,b,c,d,e,f,g, 7


#      8 6 8 7 4 9 6

# one with count 4 -> e
# e
# one with count 6 -> b
# b,e
# one with count 9 -> f
# b,e,f
# one in width 2 not in [f] -> c
# b,c,e,f
# one in width 3 not in [c,f] -> a
# a,b,c,e,f
# of those with d or g, one without a -> d
# not in [a,b,c,d,e,f] -> g

# one in all 6 that isn't a,b,d,f -> g

# "ab     ",
# "ab d   ",
# "ab  ef ",
# " bcdef ",
# "a cd fg",
# "abcd f ",
# "abcdef ",
# " bcdefg",
# "abcde g",
# "abcdefg"
# a -> d
# b
# c -> a
# d
# e
# f -> b
# g

# find the letter missing in all except one (yields f)
# the letter not shared between both 2 and 3 (yields a)
# the letter in 3 that is not a or f (yields c)
# now you know c (it is the one left over from the two pattern)
# one should have all 7 (8)

# ab -> c->a,b, f->a,b
# abd -> c->a,b, f->a,b, a->d
# abef -> a->c,f, b->c,f, e->b,d, f->b,d
# abcdefg => 8

# a -> 8
# b -> 6
# c -> 8
# d -> 7
# e -> 4
# f -> 9
# g -> 7
