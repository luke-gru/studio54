require File.join(File.expand_path(File.dirname(__FILE__)), "config/app_tie")

class Studio54::Dancefloor
  include LazyController::Routable

  get '/' do
    "yay"
  end

end

