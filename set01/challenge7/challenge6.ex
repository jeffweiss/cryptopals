defmodule Challenge6 do
  use Bitwise
  def guess_key(ciphertext) do
    for byte <- 0..255, into: [] do
      key = Stream.cycle([byte])
      plaintext = ciphertext
                  |> xor_with(key)
                  |> :binary.list_to_bin
      {byte, plaintext}
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

  def xor_with(left, right) when is_list(left) do
    zipped = Stream.zip(left, right)
    for {l, r} <- zipped, do: l ^^^ r
  end

  def xor_with(text, key) when is_binary(text) do
    text
    |> :binary.bin_to_list
    |> xor_with(key)
  end

  def encode(text) do
    text
    |> Base.encode16(case: :lower)
  end

  def hamming_distance(bin1, bin2) when is_bitstring(bin1) and is_bitstring(bin2) do
    list1 = :binary.bin_to_list(bin1)
    list2 = :binary.bin_to_list(bin2)
    hamming_distance(list1, list2)
  end
  def hamming_distance(list1, list2) when is_list(list1) and is_list(list2) do
    xbin = xor_with(list1, list2) |> :binary.list_to_bin
    bits = for <<c::1 <- xbin>>, into: [], do: c
    Enum.sum(bits)
  end
  def hamming_distance([list1, list2]) when is_list(list1) and is_list(list2) do
    hamming_distance(list1, list2)
  end

  def average(list) when is_list(list) do
    list
    |> Enum.sum
    |> Kernel./(length(list))
  end

  def pairs(list = [h, t]), do: list
  def pairs([h|t]) do
    for x <- pairs(t), into: [] do
      [h, x]
    end
    
  end

  def probable_key_sizes(ciphertext, number_of_keysizes_to_keep) do
    # for keysize <- 2..40, into: [] do
    #   <<c1::size(keysize), c2::size(keysize), _rest::bitstring>> = ciphertext
    #   {keysize, hamming_distance(<<c1>>, <<c2>>) / keysize}
    # end

    ciphertext_bytes = :binary.bin_to_list(ciphertext)

    for keysize <- 2..40, into: [] do
      distance = ciphertext_bytes
                  |> Stream.chunk(keysize)
                  |> Enum.take(10)
                  |> Enum.chunk(2, 1)
                  |> Enum.map( &hamming_distance/1 )
                  |> average
                  |> Kernel./(keysize)
      {keysize, distance}
    end
    |> IO.inspect
    |> Enum.sort_by(fn {_keysize, distance} -> distance end)
    |> Enum.take(number_of_keysizes_to_keep)
    |> Enum.map( fn {keysize, _} -> keysize end)
  end

  def file_contents(filename) do
    filename
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.join
    |> Base.decode64!
  end

  def chunk(contents, size) when is_binary(contents) do
    contents
    |> :binary.bin_to_list
    |> chunk(size)
  end
  def chunk(contents, size) when is_list(contents) do
    contents
    |> Enum.chunk(size, size, [])
    |> Enum.map(&Enum.with_index/1)
    |> List.flatten
    |> Enum.group_by( fn {_, index} -> index end)
    |> Enum.to_list
    |> Enum.map( fn {_index, list} -> Enum.map(list, fn {byte, _index} -> byte end) end)
  end


  def run_challenge do
    contents = file_contents("6.txt")
    keysizes = probable_key_sizes(contents, 2) |> IO.inspect
    
    Enum.map(keysizes, fn size -> {size, contents |> chunk(size) |> Enum.map(&guess_key/1)} end)
    |> Enum.map(fn {size, list} -> 
      key = Enum.map(list, fn {char, _} -> char end) |> List.flatten
      plaintext = contents |> xor_with(Stream.cycle(key)) |> :binary.list_to_bin
      {size, key, plaintext}
      end)
    |> Enum.sort_by( fn {_size, _key, plaintext} -> score(plaintext) end)
    |> List.last

  end
end

"1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
|> Base.decode16!(case: :mixed)
|> Challenge6.guess_key
|> IO.inspect

Challenge6.hamming_distance("this is a test", "wokka wokka!!!")
|> IO.inspect

Challenge6.run_challenge
|> IO.inspect

