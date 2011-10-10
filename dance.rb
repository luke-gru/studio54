require File.join(File.expand_path(File.dirname(__FILE__)), "config/app_tie")

# main app class
class Studio54::Dancefloor
  include LazyController::Routable

  get '/' do
    context = controller :users, :index
    # response["Cache-Control"] = "max-age=2, public"
    response.body = erb :index, {}, context
    response["Content-Length"] = response.body.inject(0) {|a, l| a+=l.length }
    [200, response.headers, response.body]
  end

end

