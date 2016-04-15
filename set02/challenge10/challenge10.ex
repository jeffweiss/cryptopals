defmodule Challenge10 do
  use Bitwise
  def file_contents(filename) do
    filename
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.join
    |> Base.decode64!
  end

  def run_challenge do
    file_contents("10.txt") 
    |> :binary.bin_to_list
    |> Enum.chunk(16)
    |> Enum.reduce({<<0>>, ""}, &decrypt/2)
    |> elem(1)
  end

  def decrypt(block, {iv, results}) do
    plaintext = decrypt(block, iv)
    {block, results <> plaintext}
  end

  def decrypt(block, iv) do
    :crypto.block_decrypt(:aes_ecb, "YELLOW SUBMARINE", block)
    |> xor_with(iv)
  end

  def encrypt(block, {iv, results}) do
    ciphertext = encrypt(block, iv)
    {ciphertext, results <> ciphertext}
  end
  def encrypt(block, iv) do
    cbc_block = xor_with(block, iv)
    :crypto.block_encrypt(:aes_ecb, "YELLOW SUBMARINE", cbc_block)
  end

  def xor_list(left, right) do
    zipped = Enum.zip(left, right)
    for {l, r} <- zipped, do: l ^^^ r
  end

  def xor_with(text, key) when is_binary(text), do: xor_with(:binary.bin_to_list(text), key)
  def xor_with(text, key) when is_binary(key), do: xor_with(text, :binary.bin_to_list(key))
  def xor_with(text, key) when is_list(text) and is_list(key) do
    key_stream = Stream.cycle(key)
    text
    |> xor_list(key_stream)
    |> :binary.list_to_bin
  end
end

Challenge10.run_challenge
|> IO.puts

