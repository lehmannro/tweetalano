# Copyright 2011 Robert Lehmann

require 'hashie/mash'

def tweet(extras)
  #XXX retweeted_status => Hashie::Mash...
  Hashie::Mash.new({
    :contributors => nil,
    :coordinates => nil,
    :created_at => "Fri Jan 1 00:00:00 +0000 2010",
    :entities => Hashie::Mash.new({
      :hashtags => [
#         Hashie::Mash.new({
#           :indices => [60, 67],
#           :text => "Berlin",
#         }),
      ],
      :urls => [
#         Hashie::Mash.new({
#           :display_url => "pycon.blogspot.com/2011/02/pycon-\342\200\24",
#           :expanded_url => "http://pycon.blogspot.com/2011/02/pycon-2011-want-to-discuss-things-want.html",
#           :indices => [84, 103],
#           :url => "http://t.co/ZETPKah",
#         }),
#         Hashie::Mash.new({
#           :expanded_url => nil,
#           :indices => [117, 137],
#           :url => "http://bit.ly/ftu910",
#         }),
      ],
      :user_mentions => [
#         Hashie::Mash.new({
#         :id => 73946259,
#         :id_str => "73946259",
#         :indices => [3, 16],
#         :name => "Planet Python",
#         :screen_name => "planetpython",
#         }),
      ],
    }),
    :favorited => false,
    :geo => nil,
    :id => 11111111111111111,
    :id_str => "11111111111111111",
    :in_reply_to_screen_name => nil,
    :in_reply_to_status_id => nil,
    :in_reply_to_status_id_str => nil,
    :in_reply_to_user_id => nil,
    :in_reply_to_user_id_str => nil,
    :place => nil,
    :retweet_count => 0,
    :retweeted => false,
    :source => "web", # "<a href=\"http://www.tweetdeck.com\" rel=\"nofollow\">TweetDeck</a>",
    :text => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    :truncated => false,
    :user => Hashie::Mash.new({
      :contributors_enabled => false,
      :created_at => "Mon Jan 1 00:00:00 +0000 2007",
      :description => "Average joe.",
      :favourites_count => 3,
      :follow_request_sent => false,
      :followers_count => 200,
      :following => true,
      :friends_count => 100,
      :geo_enabled => true,
      :id => 11111111,
      :id_str => "11111111",
      :is_translator => false,
      :lang => "en",
      :listed_count => 15,
      :location => "London, UK",
      :name => "John Doe",
      :notifications => false,
      :profile_background_color => "9AE4E8",
      :profile_background_image_url => "http://a3.twimg.com/profile_background_images/.../...jpg",
      :profile_background_tile => false,
      :profile_image_url => "http://a2.twimg.com/profile_images/.../...jpg",
      :profile_link_color => "0084B4",
      :profile_sidebar_border_color => "BDDCAD",
      :profile_sidebar_fill_color => "DDFFCC",
      :profile_text_color => "333333",
      :profile_use_background_image => true,
      :protected => false,
      :screen_name => "johndoe",
      :show_all_inline_media => false,
      :statuses_count => 12345,
      :time_zone => "London",
      :url => "http://www.john.doe/",
      :utc_offset => 0,
      :verified => false,
    }),
  }).update(extras)
end

TWEETS = [
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
  tweet({}),
]
    

module Twitter
  class << self
    def home_timeline options
      TWEETS
    end
  end
end
