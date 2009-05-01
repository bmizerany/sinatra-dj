require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname)
$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname.parent.join("lib"))

require "rack/esi"
require "rack/cache"
require "basic_example_application"

use Rack::ShowExceptions
use Rack::ESI
use Rack::CommonLogger

use Rack::Cache,
  :verbose     => true,
  :metastore   => "heap:/",
  :entitystore => "heap:/"

use Rack::ContentLength
run BasicExampleApplication.new
