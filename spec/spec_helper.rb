$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'ifin24'
require 'spec'
require 'spec/autorun'
require 'mocha'

require 'mechanize'

Spec::Runner.configure do |config|
  
end

module MechanizeTestHelper

  def fake_page(html, agent)
    html_response = { 'content-type' => 'text/html' }
    page = Mechanize::Page.new(nil, html_response, html, 200, agent)

    return page
  end

  def load_html_fixture(file_name)
    html = File.read(File.join(File.dirname(__FILE__), 'fixtures', file_name))
    return html
  end

end
