defmodule FixedXor do
  use Bitwise
  def hex_xor(left, right) do
    l_decoded = left  |> Base.decode16!(case: :mixed) |> to_char_list
    r_decoded = right |> Base.decode16!(case: :mixed) |> to_char_list
    zipped = Enum.zip(l_decoded, r_decoded)
    xorred = for {l, r} <- zipped, do: l ^^^ r
    xorred |> to_string |> Base.encode16(case: :lower)
  end
end

IO.puts FixedXor.hex_xor("1c0111001f010100061a024b53535009181c", "686974207468652062756c6c277320657965")
