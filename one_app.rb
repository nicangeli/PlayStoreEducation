require 'rubygems'
require 'mechanize'
require 'pp'

agent = Mechanize.new
page = agent.get('https://play.google.com/store/apps/details?id=uk.co.focusmm.dts_theory')

email = page.link_with(:text => 'Email Developer')
pp email.href
