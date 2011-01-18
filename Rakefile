# Copyright 2011 Robert Lehmann

require 'lib/tweetalano/version'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'tweetalano'
  s.version = Tweetalano::VERSION
  s.summary = "mutt-like twitter client"
  s.homepage = "https://github.com/lehmannro/tweetalano/"
  s.author = "Robert Lehmann"
  s.email = "tweetalano@robertlehmann.de"
  s.license = "Apache Software License"
  s.description = <<EOF
tweetalano is a console client for Twitter.
EOF
  s.platform = Gem::Platform::RUBY
  s.files = FileList.new %w{ lib/**/*.rb }
  s.executables = %w(tweetalano)
  s.add_dependency 'twitter'
  s.add_dependency 'stfl'
  s.add_dependency 'xdg'
  s.add_dependency 'oauth'
  s.add_dependency 'yaml'
  s.add_dependency 'launchy'
end

Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end 
