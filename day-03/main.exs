use Bitwise

defmodule Helpers do
  def to_integer(value) do
    String.to_integer(value, 2)
  end

  def to_integers(values) do
    values
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Helpers.to_integer/1)
  end

  def get_set_bits_and_total(value, {set_bit_counts, total}) do
    new_set_bit_counts = Enum.map(set_bit_counts, fn([selector, set_bit_count]) ->
      increment = if (value &&& selector) == 0, do: 0, else: 1
      [selector, set_bit_count + increment]
    end)
    {new_set_bit_counts, total + 1}
  end

  def determine_bit(set_bit_count, total) do
    if set_bit_count * 2 > total, do: 1, else: 0
  end

  def from_set_bit_counts_and_total_to_integer({set_bit_counts, total}) do
    Enum.map(set_bit_counts, fn([_, set_bit_count]) ->
      Helpers.determine_bit(set_bit_count, total)
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  def epsilon_rate(bit_width, gamma_rate) do
    all_ones = trunc(:math.pow(2, bit_width)) - 1
    bxor(all_ones, gamma_rate)
  end

  def power_consumption({gamma_rate, epsilon_rate}) do
    gamma_rate * epsilon_rate
  end
end

bit_width = 12 #5
set_bits_initial = Enum.map(bit_width-1..0, fn(exp) -> [trunc(:math.pow(2, exp)), 0] end)

#values = ["00100\n","11110\n","10110\n","10111\n","10101\n","01111\n","00111\n","11100\n","10000\n","11001\n","00010\n","01010\n"]
values = File.stream!("data.txt")
|> Helpers.to_integers()
|> IO.inspect(charlists: :as_lists)

set_bits_and_total = values
|> Enum.reduce({set_bits_initial, 0}, &Helpers.get_set_bits_and_total/2)
|> IO.inspect(charlists: :as_lists)

[oxygen_generator_rating] = Enum.reduce_while(bit_width-1..0, values, fn(exp, filtered) ->
  selector = trunc(:math.pow(2, exp))
  total = length(filtered)
  set_count = length(Enum.filter(filtered, fn(value) -> band(selector, value) > 0 end))
  bit = if set_count * 2 >= total, do: 1, else: 0

  result = if bit == 1,
  do: filtered |> Enum.filter(fn(value) -> band(selector, value) > 0 end),
  else: filtered |> Enum.filter(fn(value) -> band(selector, value) == 0 end)

  result
  command = if length(result) <= 1, do: :halt, else: :cont
  {command, result}
end)
|> IO.inspect(charlists: :as_lists)

[c02_scrubber_rating] = Enum.reduce_while(bit_width-1..0, values, fn(exp, filtered) ->
  selector = trunc(:math.pow(2, exp))
  total = length(filtered)
  set_count = length(Enum.filter(filtered, fn(value) -> band(selector, value) > 0 end))
  bit = if set_count * 2 >= total, do: 0, else: 1

  result = if bit == 1,
  do: filtered |> Enum.filter(fn(value) -> band(selector, value) > 0 end),
  else: filtered |> Enum.filter(fn(value) -> band(selector, value) == 0 end)

  result
  command = if length(result) <= 1, do: :halt, else: :cont
  {command, result}
end)
|> IO.inspect(charlists: :as_lists)

life_support_rating = oxygen_generator_rating * c02_scrubber_rating
life_support_rating
|> IO.inspect(charlists: :as_lists)

#Enum.reduce_while(bit_width-1..0, values, fn(exp, filtered) ->
#  result = filtered
#  |> Enum.filter(fn(value) -> band(trunc(:math.pow(2, exp))-1, value) == value end)
#  |> IO.inspect(charlists: :as_lists)
#  command = if length(result) <= 1, do: :halt, else: :cont
#  {command, result}
#end)
#|> IO.inspect(charlists: :as_lists)

set_bits_and_total
|> Helpers.from_set_bit_counts_and_total_to_integer()
|> (fn(gamma_rate) ->
  {gamma_rate, Helpers.epsilon_rate(bit_width, gamma_rate)}
end).()
|> Helpers.power_consumption()
