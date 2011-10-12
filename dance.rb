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

end

