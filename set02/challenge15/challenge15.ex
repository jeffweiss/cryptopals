defmodule Challenge15 do

  def pkcs7_validation(unpadded = <<first::size(120), last::size(8)>>) when last < 1 or last > 15 do
    unpadded
  end
  def pkcs7_validation(<<unpadded::size(120), 1>>), do: <<unpadded::size(120)>>
  def pkcs7_validation(<<unpadded::size(112), 2, 2>>), do: <<unpadded::size(112)>>
  def pkcs7_validation(<<unpadded::size(104), 3, 3, 3>>), do: <<unpadded::size(104)>>
  def pkcs7_validation(<<unpadded::size(96), 4, 4, 4, 4>>), do: <<unpadded::size(96)>>
  def pkcs7_validation(<<unpadded::size(88), 5, 5, 5, 5, 5>>), do: <<unpadded::size(88)>>
  def pkcs7_validation(<<unpadded::size(80), 6, 6, 6, 6, 6, 6>>), do: <<unpadded::size(80)>>
  def pkcs7_validation(<<unpadded::size(72), 7, 7, 7, 7, 7, 7, 7>>), do: <<unpadded::size(72)>>
  def pkcs7_validation(<<unpadded::size(64), 8, 8, 8, 8, 8, 8, 8, 8>>), do: <<unpadded::size(64)>>
  def pkcs7_validation(<<unpadded::size(56), 9, 9, 9, 9, 9, 9, 9, 9, 9>>), do: <<unpadded::size(56)>>
  def pkcs7_validation(<<unpadded::size(48), 10, 10, 10, 10, 10, 10, 10, 10, 10, 10>>), do: <<unpadded::size(48)>>
  def pkcs7_validation(<<unpadded::size(40), 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11>>), do: <<unpadded::size(40)>>
  def pkcs7_validation(<<unpadded::size(32), 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12>>), do: <<unpadded::size(32)>>
  def pkcs7_validation(<<unpadded::size(24), 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13>>), do: <<unpadded::size(24)>>
  def pkcs7_validation(<<unpadded::size(16), 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14>>), do: <<unpadded::size(16)>>
  def pkcs7_validation(<<unpadded::size(8), 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15>>), do: <<unpadded::size(8)>>
end
