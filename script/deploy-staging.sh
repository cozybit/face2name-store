#!/bin/sh

rvm system
git --git-dir=/home/teamcity/.BuildServer/system/caches/git/git-B1D9E8DE.git push git@heroku.com:warm-beach-63.git
heroku rake db:migrate db:seed --app warm-beach-63
