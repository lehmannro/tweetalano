RUBYLIB=lib:"$$RUBYLIB" bin/tweetalano 2>error.log
reset
cat error.log
