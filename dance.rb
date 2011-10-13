require File.join(File.expand_path(File.dirname(__FILE__)), "config/app_tie")

# main app class
class Studio54::Dancefloor
  include LazyController::Routable

  get '/' do
    controller :users, :index
    # response["Cache-Control"] = "max-age=2, public"
    response.body = erb :index, {}
    response.set_content_length!
    response.send(200)
  end

  get '/test_find_by' do
    controller :users, :find_by
    response.body = erb :test_find_by, {}
    response.set_content_length!
    response.send 200
  end

  get '/form' do
    controller :users, :new
    response.body = erb :form, {}
    response.set_content_length!
    response.send
  end

  post '/create_user' do
    controller :users, :create, params
    flash :notice => "you created user #{params[:user][:name]}"
    redirect to('/')
  end

end

