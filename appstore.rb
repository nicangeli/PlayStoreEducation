require 'rubygems'
require 'mechanize'
require 'pp'
require 'whois'
require 'json'
require 'public_suffix'
require 'uri/http'

agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

page = agent.get('https://itunes.apple.com/gb/genre/ios-education/id6017?mt=8&letter=A')
links = page.links.find_all do |l|
   l.attributes.attributes["href"].value.start_with?("https://itunes.apple.com/gb/app")
end

apps = []
links.each do |link|
    app = Hash.new
    app_page = link.click
    begin
        app[:title] = app_page.search('h1').text.strip
    rescue
    end
    begin
        app[:author] = app_page.search('#title h2').text.strip
    rescue
    end
    begin
        app[:website] = app_page.link_with(:dom_class => 'see-all').href.chomp.strip
    rescue
        app[:web] = app_page.link_with(:text => /.*Support/).href.chomp.strip
    end
    begin
        uri = URI.parse(app[:website])
        domain = PublicSuffix.parse(uri.host)
        domain = domain.domain.to_s
        w = Whois.whois(domain)
        p = w.parser
        admin = p.admin_contacts
        app[:admin_email] = admin[0].email
    rescue => error
    ensure
        begin
            app[:registrant_contacts] = p.registrant_contacts[0].email
        rescue
        end
    end
    pp app
    apps << app
end

pp apps.to_json
