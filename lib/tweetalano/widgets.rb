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
    if @width < tweet.user.screen_name.length and @app.config['indent_names']
      @width = tweet.user.screen_name.length
      redraw
    end
  end
  private
  def show tweet
    name = tweet.user.screen_name
    name = name.ljust @width
    label = "@<B>#{name}</> #{tweet.highlighted}"
    item = "listitem text:#{Stfl.quote(label)}"
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
    item = self[index] || return
    if item.match /^@/
      item.slice! 0
      @app.load_timeline item
    else
      Launchy.open(item)
    end
  end
  def replace ary
    clear
    ary.each do |item| self << item end
  end
end

end #module
