defmodule Challenge11 do
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

  def detect_block_mode(ciphertext) do
    ciphertext
    |> :binary.bin_to_list
    |> Enum.chunk(16)
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
    |> Enum.map(&pkcs7_padding/1)
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

