require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname)
$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname.parent.join("lib"))

require "rack/esi"
require "basic_example_application"

use Rack::ShowExceptions
use Rack::ESI
use Rack::CommonLogger

use Rack::ContentLength
run BasicExampleApplication.new
