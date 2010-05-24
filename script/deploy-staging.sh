#!/bin/sh

rvm system
git --git-dir=/home/teamcity/.BuildServer/system/caches/git/git-B1D9E8DE.git push git@heroku.com:cold-lightning-71.git
heroku rake db:migrate db:seed --app cold-lightning-71
