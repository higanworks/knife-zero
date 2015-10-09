require "knife-zero/version"

class TC_Version < Test::Unit::TestCase
  test "returns version correctly" do
    assert_equal("1.9.0.pre.1", Knife::Zero::VERSION)
  end
end
