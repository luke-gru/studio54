source :rubygems

gem "rack"
gem "rack-cache"
gem "rack-flash"
gem "sinatra"
# Check config/app_tie to see which active_support files are required.
# Note: many required files require other active_support files in turn.
gem "activesupport"
gem "activemodel"

# dbi
gem "dbi"
# dbi driver
gem "dbd-mysql"

# optional, only need if serving xml
gem "builder"

# optional, for sending email
gem "pony"

group :development do
  gem "thin"
  gem "shotgun"
end

group :test do
  gem "rack-test"
end

