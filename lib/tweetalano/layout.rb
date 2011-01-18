# Copyright 2009, 2010, 2011 Robert Lehmann

require 'tweetalano/version'

module Tweetalano

LAYOUT = <<EOF
vbox
  @.expand:0
  
* title bar
  hbox[titlebar] .height:1 .border:b
    @style_normal:fg=black,bg=cyan
    label text:"tweetalano #{VERSION}" .expand:h
    hbox[tray] tie:r
* blink does NOT work on defocused terminals
      label text:"@ " .display[replies?]:0
        style_normal:fg=blue,bg=cyan,attr=blink
      label text:"! " .display[direct?]:0
        style_normal:fg=red,bg=cyan,attr=blink
      label text:"<" .display[messages?]:0
        style_normal:fg=black,bg=cyan,attr=dim
  
* timeline
  list[tweets]
    .expand:v modal:1 richtext:1
    .display[tweets?]:1
    pos[tweets_pos]:0
    offset[tweets_offset]:
    style_focus:bg=magenta,fg=yellow,attr=bold
    style_selected:bg=magenta,fg=yellow,attr=bold
    style_B_normal:attr=bold
    style_B_selected:bg=magenta,attr=bold
    style_B_focus:bg=magenta,attr=bold

* message view
  table @.border:t @.expand:h
    textview[text] richtext:1
      style_A_normal:fg=cyan,attr=underline
      style_H_normal:fg=yellow
      style_U_normal:fg=magenta,attr=dim
      style_end:fg=black

  vbox
    list[links]
      modal:1
      pos[links_pos]:0
      .display[links?]:0
      style_focus:bg=blue,fg=yellow,attr=bold
    hbox
      label text[name]:""
      label text:" — @"
      label text[screenname]:"" style_normal:fg=white,attr=bold
    hbox
      .display[source?]:0
      label text:"from "
      label text[source]:
    label text[published]:""

  vbox
    @style_normal:bg=white,fg=black
    label text[help]:""

* input shell, prompt
  hbox
    label text:"> " style_normal:attr=dim
    input text[shell]: .expand:h modal:1
EOF

end #module
