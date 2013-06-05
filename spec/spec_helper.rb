# Add the projects lib directory to our load path so we can require libraries
# within it easily.
dir = File.expand_path(File.dirname(__FILE__))
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
SPECDIR = dir

require 'rspec'
require 'fileutils'
require 'pathname'

Pathname.glob("#{dir}/shared_contexts/*.rb") do |file|
  require file.relative_path_from(Pathname.new(dir))
end

RSpec.configure do |config|
  # config.mock_with :mocha

  config.before :each do
  end

  config.after :each do
  end
end
