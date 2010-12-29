# Copyright 2009, 2010 Robert Lehmann

require 'rubygems'
require 'twitter'
require 'oauth'
require 'stfl'
require 'xdg'
require 'yaml'

VERSION = "0.1"
LAYOUT = <<EOF
vbox
  @.expand:0
  
* title bar
  hbox .height:1 .border:b
    @style_normal:fg=black,bg=cyan
    label text:"tweetalano #{VERSION}" .expand:h
    hbox[tray] tie:r
* blink does NOT work on defocused terminals
      label text:"@ " .display[replies?]:0
        style_normal:fg=blue,bg=cyan,attr=blink
      label text:"! " .display[direct?]:0
        style_normal:fg=red,bg=cyan,attr=blink
      label text:"<" .display[messages?]:1
        style_normal:fg=black,bg=cyan,attr=dim
  
* timeline
  !list[tweets]
    .expand:v modal:1 richtext:1
    .display[tweets?]:1
    pos[tweets_pos]:0
    offset[tweets_offset]:
    style_focus:bg=magenta,fg=yellow,attr=bold
    style_selected:bg=magenta,fg=yellow,attr=bold
    style_B_normal:attr=bold
    style_B_selected:bg=magenta,attr=bold
    style_B_focus:bg=magenta,attr=bold

* detail view
  vbox .expand:v
    .display[details?]:0
    hbox
      label text[screenname]:"" style_normal:fg=white,attr=bold
      label text:" — "
      label text[name]:""
    label
    textview[text] richtext:1 .expand:v
      style_A_normal:fg=cyan,attr=underline
      style_H_normal:fg=yellow
      style_U_normal:fg=magenta,attr=dim
      style_end:fg=black
    label text[published]:""

  vbox
    @style_normal:bg=white,fg=black
    label text:"public timeline"

* input shell
  hbox
    * prompt
    label text:"> " style_normal:attr=dim
    input text[shell]: .expand:h modal:1
EOF

class Timeline < Array
  def initialize app
    @app = app
    @width = 1
  end
  def clear
    super
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
    name = tweet.user.screen_name.ljust @width
    item = "listitem text:\"@<B>#{name}</> \"#{Stfl.quote(tweet.text)}"
    @app.stfl!(:tweets, item, :append)
  end
end

class Twitsh
  def initialize
    @form = Stfl.create LAYOUT
    @timeline = Timeline.new self
    configure
    authorize
    load_timeline
  end

  def stfl!(component, value, modify=nil)
    if modify.nil? then @form.set component.to_s, value.to_s
    else @form.modify component.to_s, modify.to_s, value.to_s end
  end
  def stfl(component) @form.get component.to_s end

  def configure;
    path = XDG::Config.find('tweetalano', 'config.yaml') \
      or fail('$XDG_CONFIG_HOME/tweetalano/config.yaml not found')
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


  def load_timeline;
    # count must be "less than or equal to 200."
    Twitter.home_timeline({:count => 200}).each do |tweet|
      @timeline << tweet
    end
  end

  def show_tweet tweet
    stfl! :tweets?, 0
    stfl! :details?, 1
    stfl! :text, "listitem", :replace_inner
    if tweet.text.include? "\n"
      lines = tweet.text.split("\n")
    else
      lines = tweet.text.scan(/(.{1,79})(?:\s+|$)/).collect{|a| a[0]}
    end
    lines.each do |line|
      stfl! :text, "listitem text:#{Stfl.quote(line.strip)}", :append
    end
    stfl! :screenname, "@#{tweet.user.screen_name}"
    stfl! :name, tweet.user.name
    stfl! :published, tweet.created_at
  end

  def current_listitem() (stfl :tweets_pos).to_i end

  def main
    loop do
      event = @form.run(0)
      if event == "^C"
        break
      elsif event == "ENTER"
        show_tweet @timeline[current_listitem] if stfl :tweets? == 1
      elsif event == "BACKSPACE"
        if stfl :details? == 1
          stfl! :details?, 0
          stfl! :tweets?, 1
        end
#       else
#         @timeline << OpenStruct.new(:screenname => "event", :message => event.dump)
      end
    end #loop
  end #main
end #class

if __FILE__ == $0
  if ARGV.include?"-h" or ARGV.include?"--help"
    puts <<EOF
twitsh [options]

EOF
  else
    Twitsh.new.main
  end
end
