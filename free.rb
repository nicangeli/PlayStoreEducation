require 'rubygems'
require 'mechanize'
require 'pp'
require 'json'

agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

page = agent.get('http://localhost:8000/top_free.html')

page_links = []
page.links.each do |link|
      cls = link.attributes.attributes['class']
      page_links << link if cls && cls.value == 'title'
end

apps = []

page_links.each do |app_link|
    begin
        app = app_link.click
        title = app.search('.document-title')
        subtitle = app.search('.primary')
        score = app.search('.score')
        email = app.link_with(:text => "Email Developer")
        devSite = app.link_with(:text => "Visit Developer's Website")

        company = Hash.new
        company[:title] = title.text.strip
        company[:subtitle] = subtitle.text.strip
        company[:score] = score.text.strip
        company[:email] = email.href.strip
        company[:site] = devSite.href.strip

        apps << company
    rescue
    end
end

puts apps.to_json
