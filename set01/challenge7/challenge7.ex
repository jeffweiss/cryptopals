defmodule Challenge7 do
  def file_contents(filename) do
    filename
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.join
    |> Base.decode64!
  end

  def run_challenge do
    file_contents("7.txt") 
    |> :binary.bin_to_list
    |> decrypt
  end

  def decrypt(block) do
    :crypto.block_decrypt(:aes_ecb, "YELLOW SUBMARINE", block)
  end
end

Challenge7.run_challenge
|> IO.puts

