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
    configure!
    require 'tweetalano/mock'
    #authorize!
  end

  def stfl!(component, value, modify=nil)
    if modify.nil? then @form.set component.to_s, value.to_s
    else @form.modify component.to_s, modify.to_s, value.to_s end
  end
  def stfl(component) @form.get component.to_s end
  def focus(component) @form.set_focus component.to_s end

  def config() @config end
  def configure!;
    path = XDG['CONFIG'].find('tweetalano', 'config.yaml') \
      or fail("#{XDG::Config.home}/tweetalano/config.yaml not found")
    @config = YAML::load_file(path)
  end

  def authorize!;
    fetch_oauth! unless @config.has_key? 'oauth'
    Twitter.configure do |config|
      # In this scenario, tweetalano is the consumer and the oauth belongs to
      # the user.
      config.consumer_key = @config['consumer']['key']
      config.consumer_secret = @config['consumer']['secret']
      config.oauth_token = @config['oauth']['token']
      config.oauth_token_secret = @config['oauth']['secret']
    end
  end

  def fetch_oauth!;
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
               :include_entities => 1,}
               #:count => @config.fetch(:fetch_size, 200)}
    if user
      tweets = Twitter.user_timeline(user, options)
    else
      tweets = Twitter.home_timeline(options)
    end
    show_many tweets
  end

  def show_many tweets
    tweets.each do |tweet|
      prepare tweet
      @timeline << tweet
    end
    @form.run(-1)
    redraw
    close
  end

  def prepare tweet
    inserts = Hash.new
    tweet.refs = Array.new
    insert = lambda { |obj, tag, url|
      inserts[obj[:indices][0]] = [tag, obj[:indices][1]]
      tweet.refs << url
    }

    tweet.entities.urls.each do |ref|
      insert.call ref, 'A', ref.url
    end
    tweet.entities.hashtags.each do |tag|
      insert.call tag, 'H', "##{tag.text}"
    end
    tweet.entities.user_mentions.each do |mention|
      insert.call mention, 'U', "@#{mention.screen_name}"
    end

    text = tweet.text.unpack('U*')
    inserts.sort.each_with_index do |(pos, (tag, endpos)), offset|
      text.insert pos+offset*6, *"<#{tag}>".unpack('U*')
      text.insert endpos+offset*6+3, *"</>".unpack('U*')
    end

    text = text.pack('U*')
    text.gsub! /&lt;/, '\<'
    text.gsub! /&gt;/, '\>'

    tweet.highlighted = text
  end

  def show tweet
    @entities.replace tweet.refs

    stfl! :screenname, tweet.user.screen_name
    stfl! :name, tweet.user.name
    stfl! :source, tweet.source.gsub(
                      /^<a href="(.+?)" rel="nofollow">(.+)<\/a>$/, '\2 (\1)')
    stfl! :published, tweet.created_at
  end

  def redraw
    tweet = @timeline[(stfl :tweets_pos).to_i]
    stfl! :text, "vbox", :replace_inner
    text = tweet.highlighted
    if text.include? "\n"
      lines = text.split("\n")
    else
      lines = text.scan(/(.{1,#{stfl 'titlebar:w'}})(?:\s+|$)/).collect{|a| a[0]}
    end
    lines.reject! do |line| line.strip.empty? end

    lines.each do |line|
      stfl! :text, "label text:#{Stfl.quote(line.strip)}", :append
    end
    stfl! :padding, "vbox", :replace_inner
    (140 / (stfl 'titlebar:w').to_i - lines.size + 1).times do
      stfl! :padding, "label text:\"\"", :append
    end
  end

  def open
    stfl! :help, "BACKSPACE:Close"
    stfl! :links?, 1
    stfl! :source?, 1
    stfl! :padded?, 0
    @form.run(-1)
    focus :links
  end
  def close
    stfl! :help, "ENTER:Open"
    stfl! :links?, 0
    stfl! :source?, 0
    stfl! :padded?, 1
    focus :tweets
  end

  def main
    @form.run(-1)
    load_timeline
    loop do
      event = @form.run(0)
      if event == "^D"
        break
      elsif event == ""
        show @timeline[(stfl :tweets_pos).to_i]
        redraw
      elsif event == "BACKSPACE" or event == "ESC"
        close
      elsif event == "ENTER"
        if (stfl :links?) == "0"
          open
        else
          @entities.run((stfl :links_pos).to_i)
        end
      end
    end #loop
  end #main
end #class

end #module
