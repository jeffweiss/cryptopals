defmodule Set2 do
  def pkcs7_padding(block, size \\ 16) do
    remaining = size - byte_size(block)
    pad_with(block, remaining, remaining)
  end

  defp pad_with(block, _byte, count) when count <= 0, do: block
  defp pad_with(block, byte, count) do
    block <> <<byte>>
    |> pad_with(byte, count - 1)
  end
end
