# Copyright 2009 Robert Lehmann

require 'stfl'
require 'rubygems'
gem 'twitter4r'
require 'twitter'

class Twitsh
  @@LAYOUT = <<EOF
vbox
  @.expand:0
  
  @style_user_normal:fg=magenta,bg=black,attr=bold
  
  vbox[events]
    hbox .height:1 .border:b
      @style_normal:fg=black,bg=cyan
      label text:"twitsh" .expand:h
      hbox[tray] tie:r
        label text:"@" style_normal:fg=blue,bg=cyan,attr=blink .display[replies?]:0
        label text:"!" style_normal:fg=red,bg=cyan,attr=blink .display[direct?]:0
  
  list[tweets] .expand:vh
    .display[tweets.display]:1 pos[tweets.pos]:0 offset[tweets.offset]:0
    richtext:1
    style_normal:fg=white,bg=black
    style_selected:fg=white,bg=black,attr=bold

  textview[details] .expand:vh
    .display[details.display]:0
    @style_statuslink_normal:fg=white
    @style_a_normal:attr=underline
    @style_b_normal:attr=bold
    richtext:1
      listitem text:"<statuslink>"
      listitem[url] text:"http://twitter.com/username/status/00000000"
      listitem text:"</>"
      listitem[user] text:"User: <user>username</> / <longname>User Name</>"
      listitem text:
      listitem text:"username composes lorem ipsum."

  list[selectuser] .expand:vh
    .display[selectuser.display]:0 pos[selectuser.pos]:0
    style_normal:fg=white,bg=black
    style_selected:fg=white,bg=magenta
    richtext:1
      listitem text:"user1"
      listitem text:"user2"
  
  table
    @.border:t
    label text[username]:"> " style_normal:attr=dim
    !input text[shell]: .expand:h modal:1 bind_home:** bind_end:**
    label text[length]:
EOF
  @@TABS = [:tweets, :details, :selectuser]

  def initialize
    @active_tab = @@TABS[0]
    show_interface
    @form = Stfl.create @@LAYOUT
    @twitter = Twitter::Client.new
  end
  
  def stfl!(component, value, modify=nil)
    if modify then @form.modify component, modify, value
    else @form.set component, value end
  end
  def stfl(component) @form.get component end


  def focus_listitem(n=nil) 
    if n then @form.set(@active_tab.to_s + ".pos", n.to_s)
    else @form.get(@active_tab.to_s + ".pos").to_i end
  end
  def focus_listpage(n) # n is relative for now
    id = @active_tab.to_s + ".offset"
    @form.set id, (@form.get(id).to_i + n*@form.get(@active_tab.to_s + ":h").to_i).to_s
  end

  def show_interface(id=nil)
    return @active_tab if not id
    @@TABS.each do |name|
      @form.set(name.to_s + ".display", name == id ? "1" : "0")
    end
    @active_tab = id
  end

  def notify event, delete=false
    @form.set(event.to_s + ".display", delete ? "0" : "1")
  end

  def main
    loop do
      event = @form.run(0)
      if event == "^C"
          break
      # list navigation
      elsif event == "DOWN"
        focus_listitem focus_listitem + 1
      elsif event == "UP"
        focus_listitem [focus_listitem - 1, 0].max
      elsif event == "SHOME"
        focus_listitem 0
      elsif event == "SEND"
        focus_listitem @form.get(@active_tab.to_s + ":c").to_i
      elsif event == "PPAGE"
        focus_listpage -1
      elsif event == "NPAGE"
        focus_listpage +1
      elsif event == "^K"
        @form.modify("tweets", "append", 'listitem text:"' + @form.get("tweets:c") + '"')
      elsif event == "^D"
        @form.modify("tweets", "replace_inner", "listitem")
      end
    end
  end
end

if __FILE__ == $0
  if ARGV.include?"-h" or ARGV.include?"--help"
    puts :foo
  else
    Twitsh.new.main
  end
end
