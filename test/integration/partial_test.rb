class PartialTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Studio54

  def app
    Dancefloor.new
  end

  FULL_RENDERING = <<HTML
<html>
  <head>
    <!--
       -<link rel="stylesheet" type="text/css" href="/css/yui_reset.css" />
       -<link rel="stylesheet" type="text/css" href="/css/base.css" />
       -->
  </head>
  <body>
    <title>Site</title>
    <div id="container">
      <h1>Partial Test</h1>
  <p>I am 1 years old</p>
  <p>I am 2 years old</p>
  <p>I am 3 years old</p>
  <p>I am 4 years old</p>
  <p>I am 5 years old</p>
  <p>I am 6 years old</p>



    </div>
  </body>
</html>

HTML

  def test_partial_rendered
    get '/partial'
    app = Base.app_instance
    body = ""
    app.instance_eval do
      body += erb :partial_test
    end
    assert_equal body, last_response.body
    assert_equal true, last_response.ok?
    assert_equal true, last_response.html?
    assert_equal FULL_RENDERING, body
  end

end

