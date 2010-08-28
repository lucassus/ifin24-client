# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ifin24::Client" do
  include MechanizeTestHelper

  it "fetch account limits" do
    client = Ifin24::Client.new('login', 'password')
    agent = client.agent
    
    page = fake_page(load_html_fixture('list_limits.html'), agent)
    agent.expects(:get).with(Ifin24::Client::LIMITS_URL).returns(page)
    limits = client.fetch_limits

    limits.class.should == Hash

    limits.size.should == 8
    limits['Kursy i szkolenia'].should_not == nil
    limits['Zajęcia sportowe'].should_not == nil
    limits['Wynajem'].should_not == nil
    limits['Spłata kredytu'].should_not == nil
    limits['Wyjście do klubu/Impreza'].should_not = nil
    limits['Stołówka/ posiłki poza domem'].should_not = nil
    limits['Żywność'].should_not = nil
    limits['Opłaty bankowe'].should_not = nil

  end
  
end
