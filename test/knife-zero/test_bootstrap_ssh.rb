require 'knife-zero/bootstrap_ssh'

class TC_BootstrapSsh < Test::Unit::TestCase
  def setup
    @app = Chef::Knife::BootstrapSsh.new
    @app.merge_configs
  end

  test "RR" do
    assert_rr do
      subject = Hash.new
      mock(subject).to_json("hoge") {
        "mogemoge"
      }
      assert_equal("mogemoge", subject.to_json("hoge"))
    end
  end
end
