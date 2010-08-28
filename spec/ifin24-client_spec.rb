# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ifin24::Client" do
  include MechanizeTestHelper

  it "should fetch account limits" do
    client = Ifin24::Client.new('login', 'password')
    agent = client.agent

    page = fake_page(load_html_fixture('list_limits.html'), agent)
    agent.expects(:get).with(Ifin24::Client::LIMITS_URL).returns(page)
    limits = client.fetch_limits

    limits.class.should == Array
    limits.size.should == 8

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Kursy i szkolenia'
    limit.amount.should == 0
    limit.max.should == 200

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Zajęcia sportowe'
    limit.amount.should == 0
    limit.max.should == 100

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Wynajem'
    limit.amount.should == 670
    limit.max.should == 800

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Spłata kredytu'
    limit.amount.should == 342.27
    limit.max.should == 700

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Wyjście do klubu/Impreza'
    limit.amount.should == 291
    limit.max.should == 200

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Stołówka/ posiłki poza domem'
    limit.amount.should == 278.49
    limit.max.should == 200

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Żywność'
    limit.amount.should == 166.15
    limit.max.should == 500

    limit = limits.shift
    limit.should_not == nil
    limit.name.should == 'Opłaty bankowe'
    limit.amount.should == 6.50
    limit.max.should == 20
  end

end
