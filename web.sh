#!/bin/bash

if [ -z "$RAILS_ENV" ]; then
  cd game_server
  bundle exec jruby server.rb -p $PORT -h 0.0.0.0
else
  cd web_server
  bundle exec rails server -p $PORT
fi
