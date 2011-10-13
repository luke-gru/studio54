require File.join(File.expand_path(File.dirname(__FILE__)), "config/app_tie")

# main app class
class Studio54::Dancefloor
  include LazyController::Routable

  get '/' do
    @context = controller :users, :index
    # response["Cache-Control"] = "max-age=2, public"
    response.body = erb :index, {}, @context
    response.set_content_length!
    response.send(200)
  end

  get '/test_find_by' do
    @context = controller :users, :find_by
    response.body = erb :test_find_by, {}, @context
    response.set_content_length!
    response.send 200
  end

  get '/form' do
    @context = controller :users, :new
    response.body = erb :form, {}, @context
    response.set_content_length!
    response.send
  end

  post '/create_user' do
    controller :users, :create, params
    redirect to('/')
  end

end

