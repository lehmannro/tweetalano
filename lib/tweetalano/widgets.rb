# Copyright 2010, 2011 Robert Lehmann

require 'launchy'

module Tweetalano

class Timeline < Array
  def initialize app
    @app = app
  end
  def clear
    super
    @app.stfl! :tweets_pos, 0
    @width = 1
    redraw
  end
  def redraw
    @app.stfl! :tweets, "listitem", :replace_inner # clear
    each do |tweet| show tweet end
  end
  def << tweet
    push tweet
    show tweet
    if @width < tweet.user.screen_name.length
      @width = tweet.user.screen_name.length
      redraw
    end
  end
  private
  def show tweet
    name = tweet.user.screen_name
    name = name.ljust @width if @app.config['indent_names']
    item = "listitem text:\"@<B>#{name}</> \"#{Stfl.quote(tweet.text)}"
    @app.stfl! :tweets, item, :append
  end
end

class Entities < Array
  def initialize app
    @app = app
  end
  def clear
    super
    @app.stfl! :links, "listitem", :replace_inner # clear
  end
  def << item
    super item
    @app.stfl! :links, "listitem text:#{Stfl.quote(item)}", :append
  end
  def run index
    item = self[index]
    STDERR.puts item.dump
    if item.match /^@/
      STDERR.puts "timeline"
      item.slice! 0
      @app.load_timeline item
    else
      STDERR.puts "launchy"
      Launchy.open(item)
    end
  end
end

end #module
