defmodule Challenge13 do
  use Bitwise

  def random_key do
    :crypto.strong_rand_bytes(16)
  end

  def encryption_oracle(plaintext) do
    key = random_key
    iv = random_key
    data = random_data <> plaintext <> random_data
    case :crypto.rand_uniform(0, 2) do
      0 -> encrypt_cbc(data, key, iv)
      1 -> encrypt_ecb(data, key, iv)
    end
  end

  def detect_block_mode(ciphertext, key_size \\ 16) do
    ciphertext
    |> :binary.bin_to_list
    |> Enum.chunk(key_size)
    |> number_of_repeated_blocks
    |> case do
      0 -> :cbc
      _ -> :ecb
    end
  end

  defp number_of_repeated_blocks(list) do
    before_size = Enum.count(list)
    uniqs = Enum.uniq(list)
    before_size - Enum.count(uniqs)
  end

  def encrypt_cbc(data, key, iv) do
    data
    |> :binary.bin_to_list
    |> Enum.chunk(16, 16, [])
    # |> Enum.map(&pkcs7_padding/1)
    |> Enum.reduce({iv, "", key}, &encrypt/2)
    |> elem(1)
  end

  def encrypt_ecb(data, key, _iv) do
    data
    |> :binary.bin_to_list
    |> Enum.chunk(16, 16, [])
    |> Enum.map(&pkcs7_padding/1)
    |> Enum.map(&encrypt(&1, key))
    |> Enum.join
  end

  def decrypt_cbc(data, key, iv) do
    data
    |> :binary.bin_to_list
    |> Enum.chunk(16)
    |> Enum.map(&pkcs7_padding/1)
    |> Enum.reduce({iv, "", key}, &decrypt/2)
    |> elem(1)
  end

  def decrypt_ecb(data, key, _iv) do
    data
    |> :binary.bin_to_list
    |> Enum.chunk(16)
    |> Enum.map(&pkcs7_padding/1)
    |> Enum.map(&decrypt(&1, key))
    |> Enum.join
  end

  defp random_data do
    :crypto.rand_uniform(5, 11)
    |> :crypto.strong_rand_bytes
  end

  def decrypt(block, {iv, results, key}) do
    plaintext = decrypt(block, key) |> xor_with(iv)
    {block, results <> plaintext, key}
  end

  def decrypt(block, key) do
    :crypto.block_decrypt(:aes_ecb, key, block)
  end

  def encrypt(block, {iv, results, key}) do
    ciphertext =
      block
      |> xor_with(iv)
      |> encrypt(key)
    {ciphertext, results <> ciphertext, key}
  end

  def encrypt(block, key) do
    :crypto.block_encrypt(:aes_ecb, key, block)
  end

  defp xor_list(left, right) do
    zipped = Enum.zip(left, right)
    for {l, r} <- zipped, do: l ^^^ r
  end

  defp xor_with(text, key) when is_binary(text), do: xor_with(:binary.bin_to_list(text), key)
  defp xor_with(text, key) when is_binary(key), do: xor_with(text, :binary.bin_to_list(key))
  defp xor_with(text, key) when is_list(text) and is_list(key) do
    key_stream = Stream.cycle(key)
    text
    |> xor_list(key_stream)
    |> :binary.list_to_bin
  end
  def pkcs7_padding(block, size \\ 16)
  def pkcs7_padding(block, size) when is_list(block) do
    remaining = size - length(block)
    pad_with(block, remaining, remaining)
  end
  def pkcs7_padding(block, size) when is_binary(block) do
    remaining = size - byte_size(block)
    pad_with(block, remaining, remaining)
  end

  defp pad_with(block, _byte, count) when count <= 0, do: block
  defp pad_with(block, byte, count) when is_list(block) do
    block ++ [byte]
    |> pad_with(byte, count - 1)
  end
  defp pad_with(block, byte, count) when is_binary(block) do
    block <> <<byte>>
    |> pad_with(byte, count - 1)
  end
end
defmodule Challenge13Decryption do
  @key :crypto.strong_rand_bytes(16)
  @text "Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkgaGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBqdXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUgYnkK"

  def c13(plaintext) do
    key = @key
    data = plaintext <> Base.decode64!(@text)
    |> Challenge13.pkcs7_padding
    Challenge13.encrypt_ecb(data, key, <<0>>)
  end

  def detect_key_size(max \\ 32) do
    [min, max] =
      for count <- 1..max do
        Stream.cycle([65])
        |> Enum.take(count)
        |> :binary.list_to_bin
        |> c13
        |> byte_size
      end
      |> Enum.uniq
      |> Enum.take(2)
    max - min
  end

  defp preface_for_block(number, key_size) do
    auto =
      [65]
      |> Stream.cycle
      |> Enum.take((number + 1) * key_size - 1 )
      |> :binary.list_to_bin
    auto 
  end
  
  defp ciphertext_for_block(number, key_size) do
    number
    |> preface_for_block(key_size)
    |> c13
    |> :binary.bin_to_list
    |> Enum.chunk(key_size)
    |> Enum.at(number)
  end

  def single_byte_decryption do
    key_size = detect_key_size
    IO.puts "Detected key size of #{key_size} bytes"
    encryption_mode = Challenge13.detect_block_mode(c13("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"), key_size)
    IO.puts "Detected #{encryption_mode} block mode"
    ciphertext_length = c13("") |> byte_size
    IO.puts "Detected ciphertext length of #{ciphertext_length} bytes"

    0..ciphertext_length-1
    |> Enum.reduce({key_size, []}, &reduce/2)
    |> elem(1)
    |> IO.puts
  end

  def reduce(n, {key_size, result_so_far}) do
    block_number = working_block_number(n, key_size)
    p_needed = preface_characters_needed(n, block_number, key_size)

    fixed_preface =
      [65]
      |> Stream.cycle
      |> Enum.take(p_needed)

    preface =
      fixed_preface ++ result_so_far
      |> Enum.chunk(key_size, key_size, [0])
      |> Enum.at(block_number)
      |> Enum.take(key_size - 1)
      |> :binary.list_to_bin

    rainbow_table =
      for byte <- 0..255, into: %{} do
        header = preface <> <<byte>>
        block =
          header
          |> c13
          |> :binary.bin_to_list
          |> Enum.take(key_size)

        {block, byte}
      end

    block =
      fixed_preface
      |> :binary.list_to_bin
      |> c13
      |> :binary.bin_to_list
      |> Enum.chunk(key_size)
      |> Enum.at(block_number)
    character = Map.get(rainbow_table, block, 0)
    {key_size, result_so_far ++ [character]}
  end

  defp working_block_number(character_number, key_size) do
    div(character_number, key_size)
  end

  defp preface_characters_needed(character_number, block, key_size) do
    (block + 1) * key_size - 1 - character_number
  end

end
