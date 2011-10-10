require "sinatra/base"
cur_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift cur_dir unless $:.include? cur_dir
require 'config/environment'
include Studio54::Config::Environment
# lots of requires found in app_tie
require 'app_tie'

class Studio54::RackInspect < Sinatra::Base
end

# main app
class Studio54::Dancefloor < Sinatra::Base
  include LazyController::Routable

  set :views, settings.root + '/public'
  set :method_override, true
  set :inline_templates, true
  set :static, true

  configure :development do
    set :logging, true
  end

  helpers do
    def logger
      request.logger
    end
  end

  before do
    load 'db/connect.rb'
    req = request
    logger.class_eval do
      cattr_accessor :format
      self.__send__ :format=, <<-HTML
#{Time.now}
#{req.request_method} #{req.fullpath}
Content-Length: #{req.content_length}
Params:#{req.params}
HTML
    end
    logger.info logger.format
  end

  get '/' do
    context = controller :users, :index
    erb :index, {}, context
  end

end

