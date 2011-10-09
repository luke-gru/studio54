require "sinatra"
$:.unshift File.expand_path('.') unless $:.include? File.expand_path('.')
require 'config/environment'
include Studio54::Config::Environment
# lots of requires found in app_tie
require 'app_tie'
include LazyController::Routable

set :views, settings.root + '/public'

get '/' do
  context = controller :users, :index
  erb :index, {}, context
end

