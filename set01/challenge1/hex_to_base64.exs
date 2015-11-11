defmodule HexToBase64 do
  # This will create a list of tuples that looks like
  # [{?A, 0}, {?B, 1}, ... {?/, 63}]
  base16_alphabet = Enum.with_index '0123456789abcdef'
  base64_alphabet = Enum.with_index 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

  # Let's then run through the list dynamically creating functions for encoding and decoding
  # defp encode64_byte(0), do: ?A
  # defp encode64_byte(1), do: ?B
  for {encoding, value} <- base64_alphabet do
    defp encode64(unquote(value)), do: unquote(encoding)
    defp decode64(unquote(encoding)), do: unquote(value)
  end
  for {encoding, value} <- base16_alphabet do
    defp encode16(unquote(value)), do: unquote(encoding)
    defp decode16(unquote(encoding)), do: unquote(value)
  end

  def do_decode16(<<>>), do: <<>>
  def do_decode16(bitstring) do
    # coming in we have a string of characters that are each represented by a full 8 bits (because
    # we're using an ASCII-encoded string to represent a a value
    # however, the result of the decode will only be 4 bits (because this is base16)
    for <<c::8 <- bitstring>>, into: <<>> do
      <<decode16(c)::4>>
    end
  end

  def do_encode64(<<>>), do: <<>>
  def do_encode64(bitstring) do
    for <<c::6 <- bitstring>>, into: <<>> do
      <<encode64(c)>>
    end
  end


  def easy_convert(string) do
    string
    |> Base.decode16!(case: :mixed)
    |> Base.encode64
  end

  def hard_convert(string) do
    string
    |> do_decode16
    |> do_encode64
  end

end

IO.puts HexToBase64.easy_convert("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d")
IO.puts HexToBase64.hard_convert("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d")


