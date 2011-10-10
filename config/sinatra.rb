class Studio54::Dancefloor < Sinatra::Base

  set :app_file, __FILE__

  configure :development do
    set :server, %w[thin webrick]
    set :dump_errors, false
    set :shotgun, false
  end

  configure :production do
    set :shotgun, false
  end

  # app root dir
  set :root, File.join(File.expand_path(File.dirname(__FILE__)), '..')
  ### Static Files ###
  # serve static files
  set :static, true
  # static file directory, served_from => :views.
  # To override Sinatra's wrapping of rack/static, disable
  # set :static and set :public_folder and explicity use
  # Rack::Static from config.ru.
  ##
  set :public_folder, Proc.new { File.join(root, 'static') }
  # template files directory
  set :views,  Proc.new { File.join(root, 'public') }
  # enable sessions
  set :sessions, true
  # using _method (PUT, DELETE)
  set :method_override, true
end

