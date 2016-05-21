require 'minitest/autorun'
require 'vcard-to-fritz'

class VCardToFritzTest < Minitest::Test


  def test_read_vcf
    conv = VCardToFritz.new('test/read.vcf', 'foo.xml')
    arr = conv.read_vcf()
    refute_nil(arr)
    assert_equal(1, arr.size)

    assert_equal(
      {"realName" => "Hagbard Celine",
       "work" => [], "mobile" => ["+49 177 234577"], "home" => ["+49 40 234577"]},
      arr[0])
  end
  
end
