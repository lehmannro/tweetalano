#!/usr/bin/ruby -w
# Copyright 2009, 2010, 2011 Robert Lehmann

require 'rubygems'
require 'tweetalano/layout'
require 'tweetalano/widgets'
require 'twitter'
require 'oauth'
require 'stfl'
require 'xdg'
require 'yaml'

module Tweetalano

class App
  def initialize
    @form = Stfl.create LAYOUT
    @timeline = Timeline.new self
    @entities = Entities.new self
    configure
    authorize
    load_timeline
  end

  def stfl!(component, value, modify=nil)
    if modify.nil? then @form.set component.to_s, value.to_s
    else @form.modify component.to_s, modify.to_s, value.to_s end
  end
  def stfl(component) @form.get component.to_s end
  def focus(component) @form.set_focus component.to_s end

  def config() @config end
  def configure;
    path = XDG::Config.find('tweetalano', 'config.yaml') \
      or fail("#{XDG::Config.home}/tweetalano/config.yaml not found")
    @config = YAML::load_file(path)
  end

  def authorize;
    fetch_oauth unless @config.has_key? 'oauth'
    Twitter.configure do |config|
      config.consumer_key = @config['consumer']['key']
      config.consumer_secret = @config['consumer']['secret']
      config.oauth_token = @config['oauth']['token']
      config.oauth_token_secret = @config['oauth']['secret']
    end
  end

  def fetch_oauth;
    consumer = OAuth::Consumer.new(
      @config['consumer']['key'], @config['consumer']['secret'], {
      :site => "http://twitter.com",
    })
    request_token = consumer.get_request_token
    puts request_token.authorize_url
    pin = STDIN.readline.strip
    access_token = request_token.get_access_token(:oauth_verifier => pin)
    @config['oauth'] = {
      'token' => access_token.token,
      'secret' => access_token.secret,
    }
    STDERR.puts access_token.token
    STDERR.puts access_token.secret
  end


  def load_timeline(user=nil)
    # count must be "less than or equal to 200."
    @timeline.clear
    options = {:include_rts => 1,
               :include_entities => 1,
               :count => 200}
    if user
      timeline = Twitter.user_timeline(user, options)
    else
      timeline = Twitter.home_timeline(options)
    end
    timeline.each do |tweet|
      @timeline << tweet
    end
    @form.run(-1)
    redraw
    close
  end

  def show_tweet tweet
    stfl! :text, "listitem", :replace_inner
    if tweet.text.include? "\n"
      lines = tweet.text.split("\n")
    else
      width = stfl 'titlebar:w'
      lines = tweet.text.scan(/(.{1,#{width}})(?:\s+|$)/).collect{|a| a[0]}
    end
    lines.each do |line|
      stfl! :text, "listitem text:#{Stfl.quote(line.strip)}", :append
    end
    stfl! :screenname, tweet.user.screen_name
    stfl! :name, tweet.user.name
    stfl! :source, tweet.source.gsub(/^<a href="(.+?)" rel="nofollow">(.+)<\/a>$/, '\2 (\1)')
    stfl! :published, tweet.created_at

    @entities.clear
    tweet.entities.urls.each do |ref|
      @entities << ref.url
    end
    tweet.entities.hashtags.each do |tag|
      @entities << "##{tag.text}"
    end
    tweet.entities.user_mentions.each do |mention|
      @entities << "@#{mention.screen_name}"
    end
  end
  def redraw
    show_tweet @timeline[(stfl :tweets_pos).to_i]
  end

  def open
    stfl! :help, "BACKSPACE:Close"
    stfl! :links?, 1
    stfl! :source?, 1
    @form.run(-1)
    focus :links
  end
  def close
    stfl! :help, "ENTER:Open"
    stfl! :links?, 0
    stfl! :source?, 0
    focus :tweets
  end

  def main
    loop do
      event = @form.run(0)
      if event == "^D"
        break
      elsif event == ""
        redraw
      elsif event == "BACKSPACE" or event == "ESC"
        close
      elsif event == "ENTER"
        if (stfl :links?) == "0"
          STDERR.puts "opening tweet"
          open
        else
          STDERR.puts "running entity!"
          @entities.run((stfl :links_pos).to_i)
        end
      end
    end #loop
  end #main
end #class

end #module
