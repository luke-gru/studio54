class MailTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Studio54

  def app
    Dancefloor.new
  end

  def test_send_email_with_pony
    post '/email/send'
    assert_equal true, last_response.errors.empty?
  end
end

