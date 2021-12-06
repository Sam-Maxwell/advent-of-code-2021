days = 256
first_gestation = 8
gestation = 6

#"3,4,3,1,2"
File.read!("data.txt")
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
#|> (fn(ages) ->
#  IO.inspect({'Initial state:', ages}, charlist: :as_lists)
#  ages
#end).()
|> (fn(ages) ->
  ages = Enum.reduce(1..days, ages, fn(_, ages) ->
    ages = Enum.map(ages, fn(age) ->
      age - 1
    end)
    births = Enum.reduce(ages, 0, fn(age, births) ->
      births + if age < 0, do: 1, else: 0
    end)
    new_fish = if births == 0,
      do: [],
      else: Enum.map(0..births-1, fn(_) ->
        first_gestation
      end)
    ages = Enum.map(ages, fn(age) ->
      if age < 0, do: gestation, else: age
    end) ++ new_fish
#    IO.inspect({'After #{day} days:', ages}, charlist: :as_lists)
    ages
  end)
end).()
#|> IO.inspect(charlist: :as_lists)
|> length()
|> IO.inspect(charlist: :as_lists)
