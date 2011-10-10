cur_dir = File.expand_path(File.dirname(__FILE__))
require File.join(cur_dir, 'dance')
use Rack::Cache,
  :verbose     => true,
  :metastore   => "file:#{cur_dir}/rack/cache/meta",
  :entitystore => "file:#{cur_dir}/rack/cache/body"

run Studio54::Dancefloor

