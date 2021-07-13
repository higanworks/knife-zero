require 'knife-zero/version'

class TC_Version < Test::Unit::TestCase
  test 'returns version correctly' do
    assert_equal('2.4.0.dev', Knife::Zero::VERSION)
  end
end
