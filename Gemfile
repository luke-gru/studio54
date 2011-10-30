source :rubygems

gem "rack"
gem "rack-cache"
gem "rack-flash"
gem "sinatra"
# Check config/app_tie to see which active_support files are required.
# Note: many required files require other active_support files in turn.
gem "activesupport"
# note, ActiveModel::Callbacks is not extended by default, unlike
# ActiveSupport::Callbacks.
gem "activemodel"

# optional, only need it if serving xml
gem "builder"

# dbms
gem "mysql"

group :development do
  gem "thin"
  gem "shotgun"
end

group :test do
  gem "rack-test"
end

