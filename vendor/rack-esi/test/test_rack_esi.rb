require "pathname"

$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname)
$LOAD_PATH.unshift(Pathname(__FILE__).expand_path.dirname.parent.join("lib"))

require "test/unit"
require "rack/esi"

class TestRackESI < Test::Unit::TestCase
  def test_response_passthrough
    mock_app = const([200, {}, ["Hei!"]])
    esi_app = Rack::ESI.new(mock_app)

    assert_same_response(mock_app, esi_app)
  end

  def test_xml_response_passthrough
    mock_app = const([200, {"Content-Type" => "text/xml"}, ["<p>Hei!</p>"]])
    esi_app = Rack::ESI.new(mock_app)

    assert_same_response(mock_app, esi_app)
  end

  def test_respect_for_content_type
    mock_app = const([200, {"Content-Type" => "application/x-y-z"}, ["<esi:include src='/header'/><p>Hei!</p>"]])
    esi_app = Rack::ESI.new(mock_app)

    assert_same_response(mock_app, esi_app)
  end

  def test_include
    app = Rack::URLMap.new({
      "/"       => const([200, {"Content-Type" => "text/xml"}, ["<esi:include src='/header'/>, Index"]]),
      "/header" => const([200, {"Content-Type" => "text/xml"}, ["Header"]])
    })

    esi_app = Rack::ESI.new(app)

    expected_body = ["Header, Index"]

    actual_body = esi_app.call("SCRIPT_NAME" => "", "PATH_INFO" => "/")[2]

    assert_equal(expected_body, actual_body)
  end

  def test_invalid_include_element_exception
    mock_app = const([200, {"Content-Type" => "text/xml"}, ["<esi:include/>"]])
    esi_app = Rack::ESI.new(mock_app)

    assert_raise Rack::ESI::Error do
      esi_app.call({})
    end
  end

  def test_remove
    mock_app = const([200, {"Content-Type" => "text/xml"}, ["<p>Hei! <esi:remove>Hei! </esi:remove>Hei!</p>"]])

    esi_app = Rack::ESI.new(mock_app)

    expected_body = ["<p>Hei! Hei!</p>"]

    actual_body = esi_app.call("SCRIPT_NAME" => "", "PATH_INFO" => "/")[2]

    assert_equal(expected_body, actual_body)
  end

  def test_comment
    mock_app = const([200, {"Content-Type" => "text/xml"}, ["<p>(<esi:comment text='*'/>)</p>"]])

    esi_app = Rack::ESI.new(mock_app)

    expected_body = ["<p>()</p>"]

    actual_body = esi_app.call("SCRIPT_NAME" => "", "PATH_INFO" => "/")[2]

    assert_equal(expected_body, actual_body)
  end

  def test_setting_of_content_length
    mock_app = const([200, {"Content-Type" => "text/html"}, ["Osameli. <esi:comment text='*'/>"]])

    esi_app = Rack::ESI.new(mock_app)

    response = esi_app.call("SCRIPT_NAME" => "", "PATH_INFO" => "/")

    assert_equal("9", response[1]["Content-Length"])
  end

  private

  def const(value)
    lambda { |*_| value }
  end

  def assert_same_response(a, b)
    x = a.call({})
    y = b.call({})

    assert_equal(x,           y)
    assert_equal(x.object_id, y.object_id)
  end
end