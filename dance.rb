require "sinatra"
cur_dir = File.expand_path File.dirname(__FILE__)
$:.unshift cur_dir unless $:.include? cur_dir
require 'config/environment'
# lots of requires found in app_tie
require 'app_tie'

# these middlewares need to go to their own dir/
class Studio54::SinatraTastes < Sinatra::Base
  set :environment, "development"

  configure do
    set :views, settings.root + '/public'
    set :logging, true
    set :static, true
    set :method_override, true
    set :inline_template, true
  end

  configure :production do end
  configure :development do end
  configure :test do end
end

class Studio54::Router < Sinatra::Base
  include ::Studio54::Config::Environment
  include ::LazyController::Routable

  get '/' do
    context = controller :users, :index
    erb :index, {}, context
  end
end

# base class for app
class Studio54::Dancefloor < Sinatra::Base
  include Studio54::Config::Environment
  use ::Studio54::SinatraConfig
  use ::Studio54::Router

  run! if app_file == $0

end


