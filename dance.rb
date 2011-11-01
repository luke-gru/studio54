require File.join(File.expand_path(File.dirname(__FILE__)), "config", "app_tie")

# main app class
#
# this is all test logic, to test the library files
# in studio54/lib
#
# the corresponding unit and integration test are in
# studio54/test/unit and studio54/test/integration
#
# along with those are some email tests (studio54/test/email)
# to test the default studio54 email gem: pony.
class Studio54::Dancefloor
  include LazyController::Routable

  get '/' do
    controller :users, :index
    # response["Cache-Control"] = "max-age=2, public"
    flash[:notice] = "hi"
    response.body = erb :index
    response.send
  end

  get '/test_find_by' do
    controller :users, :find_by
    response.body = erb :test_find_by
    response.send
  end

  get '/form' do
    controller :users, :new
    response.body = erb :form
    response.send
  end

  get '/all' do
    controller :users, :all
    response.body = erb :all
    response.send
  end

  get '/partial' do
    @content = [1,2,3]
    @partial_content = [4,5,6]
    response.body = erb :partial_test
    response.send
  end

  post '/create_user' do
    res = controller :users, :create, params
    if res
      flash[:notice] = "you created user #{@user.name}"
      redirect to('/all')
    else
      flash[:error] = @user.errors
      redirect to('/form')
    end
  end

  post '/email/send' do
    Pony.mail :to =>  'luke.gru@gmail.com',
              :via => :smtp,
      :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'luke.gru@gmail.com',
        :password => ENV['PASS'],
        :authentication => :plain,
        :domain =>  "localhost.localdomain",
        :headers => {"Content-Type" => 'text/plain'}
    },
      :subject => 'Hey, this is a really great idea',
      :body =>    'Hi me!'
  end
end

