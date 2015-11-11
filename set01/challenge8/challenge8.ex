defmodule Challenge8 do
  def run_challenge do
    File.stream!("8.txt")
    |> Stream.map(&String.strip/1)
    |> Stream.map(&Base.decode16!(&1, case: :mixed))
    |> Stream.map(&:binary.bin_to_list/1)
    |> Stream.map(&(Enum.chunk(&1, 16)))
    |> Stream.reject(fn(x) -> number_of_repeated_blocks(x) == 0 end)
    |> Enum.take(5)
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&:binary.list_to_bin/1)
    |> Enum.map(&Base.encode16(&1, case: :lower))
  end

  def number_of_repeated_blocks(list) do
    before_size = Enum.count(list)
    uniqs = Enum.uniq(list)
    before_size - Enum.count(uniqs)
  end

end

Challenge8.run_challenge
|> IO.inspect
