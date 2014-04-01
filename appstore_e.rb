require 'rubygems'
require 'mechanize'
require 'pp'
require 'whois'
require 'json'
require 'public_suffix'
require 'uri/http'

$agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

page = $agent.get('https://itunes.apple.com/gb/genre/ios-education/id6017?mt=8&letter=E')
apps = []

def get_app_details link
    begin
    app = Hash.new
    agent = Mechanize.new { | agent | 
        agent.user_agent_alias = 'Mac Safari'
    }
    app_page = agent.get(link.href)
    app[:title] = app_page.search('h1').text.strip
    app[:author] = app_page.search('#title h2').text.strip
    begin
        app[:website] = app_page.link_with(:dom_class => 'see-all').href.chomp.strip
    rescue
        app[:website] = app_page.link_with(:text => /.*Support/).href.chomp.strip
    end
    begin
        uri = URI.parse(app[:website])
        domain = PublicSuffix.parse(uri.host)
        domain = domain.domain.to_s
        w = Whois.whois(domain)
        p = w.parser
        admin = p.admin_contacts
        registrant = p.registrant_contacts
        app[:email] = admin[0].email || registrant[0].email
    rescue
    end

    if app[:email]
        return app
    end
    rescue
    end
end


until $agent.page.link_with(:text => 'Next').nil? do 
    links = page.links.find_all do |l|
        l.attributes.attributes["href"].value.start_with?("https://itunes.apple.com/gb/app")
    end
    links.each do |l|
        app_details =  get_app_details(l)
        if app_details
            apps << app_details
            pp app_details
        end
    end

    pp 'Moving on to next page'
    # agent.page.links
    page = $agent.page.link_with(:text => 'Next').click
end

File.open('appstore_e.json', 'w') do |f|
    f.write(apps.to_json)
end
