defmodule Helpers do
  def compute_final_position({horizontal_position, depth, _}) do
    horizontal_position * depth
  end

  def convert_distance_to_integer([direction, distance_string]) do
    [direction, String.to_integer(distance_string)]
  end

  def do_command([direction, units], {horizontal_position, depth, aim}) do
    case direction do
      "down" -> {horizontal_position, depth, aim + units}
      "forward" -> {horizontal_position + units, depth + (units * aim), aim}
      "up" -> {horizontal_position, depth, aim - units}
    end
  end

  def parse_command(command) do
    command
    |> String.split(" ")
    |> Helpers.convert_distance_to_integer()
  end
end

#["forward 5","down 5","forward 8","up 3","down 8","forward 2"]
File.stream!("data.txt")
|> Enum.map(&String.trim/1)
|> Enum.map(&Helpers.parse_command/1)
|> Enum.reduce({0,0,0}, &Helpers.do_command/2)
|> Helpers.compute_final_position()
|> IO.inspect(charlists: :as_lists)