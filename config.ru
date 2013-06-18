libdir = File.expand_path('..', __FILE__) + "/lib"
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

ENV['RACK_ENV'] ||= 'development'

require 'puppet_community_data/web_app'
run PuppetCommunityData::WebApp
