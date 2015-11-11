defmodule SingleByteXor do
  use Bitwise
  def guess_key(ciphertext) do
    for byte <- 0..255, into: [] do
      {byte, xor_with(ciphertext, [byte])}
    end
    |> Enum.sort_by(fn {_byte, plaintext} -> score(plaintext) end)
    |> List.last
  end

  def score(plaintext) do
    if String.printable?(plaintext) do
      words = String.split(plaintext)
      space_count = (String.split(plaintext, " ") |> length) - 1
      10 + length(words) + 2 * space_count
    else
      0
    end
  end

  def count_dictionary_words(words) do
    _unique_words = Enum.into(words, HashSet.new) |> Enum.sort
  end

  def xor_list(left, right) do
    zipped = Enum.zip(left, right)
    for {l, r} <- zipped, do: l ^^^ r
  end

  def xor_with(text, key) do
    key_stream = Stream.cycle(key)
    text
    |> Base.decode16!(case: :mixed)
    |> :binary.bin_to_list
    |> xor_list(key_stream)
    |> to_string
  end
end

File.stream!("4.txt")
|> Enum.map(&String.strip/1)
|> Enum.map(fn (line) ->
  {key, plaintext} = SingleByteXor.guess_key(line)
  {line, key, plaintext}
end)
|> Enum.sort_by(fn {_line, _key, plaintext} -> SingleByteXor.score(plaintext) end)
|> List.last
|> IO.inspect
