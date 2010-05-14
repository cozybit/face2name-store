README.txt

face2name Store - May 2010 - Carbon Five

The f2n store is where face2name customers will buy licenses so
that the f2n store will work for particular events.

Specs for Configuration Bundle
-----------------------------
    https://123.writeboard.com/c81a2c60a098b49d8
    (subversion)/face2name\docs\notes\config_bundle\config_bundle_spec.txt
    (subversion)/face2name\keys\config_bundles\how_to.txt

To install the face2name Store on your machine:
-------------------------------------------------

Install RVM (optional but it's what I use below)
    bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-latest )
    And then follow directions about appending something to your .bashrc

Install Ruby
    rvm install ruby-1.8.7-p249
    rvm use ruby-1.8.7-p249
    Check with "rvm list" or "rfm info" to see that we are using ___-p249
    
Install Rails 3
    gem install tzinfo builder memcache-client rack rack-test rack-mount erubis mail text-format thor bundler i18n
    gem install rails --pre

Install Sqlite
    gem install ruby-devel
    gem install sqlite3-ruby

Install Devise
    gem install devise --version=1.1.rc1
    Add it to f2nstore/Gemfile
    rails generate devise_install
    
Checkout f2n Store from Subversion
    svn co https://cozybit.svn.cvsdude.com/f2nstore/trunk/f2nstore_rails
    (creates a f2nstore_rails folder in the current folder)

Run Tests
    rails test

Run Rails
    cd f2nstore_rails/f2nstore
    rails server
    (open browser to http://localhost:3000 )


Publish app to Heroku 
---------------------

Run the DEPLOY/deploy.py script.

# OLD
#Copied from: http://docs.heroku.com/git#using-subversion-or-other-revision-control-systems)
#    
#    First time only:
#        Install GIT on your machine
#            See http://git-scm.com/
#        
#        Create GIT repository on your machine, ignoring .svn files
#            cd {svn}/f2nstore_rails
#            git init
#            echo .svn >> .gitignore
#            git add .
#            git commit -m "using git for heroku deployment"
#            
#        Now tell Subversion to ignore Git:
#        
#            svn propset svn:ignore .git .
#            (Subversion replies: property 'svn:ignore' set on '.')
#            svn commit -m "ignoring git folder (git is used for heroku deployment)"
#
#    Each time you wish to deploy to Heroku:
#    
#        git add .
#        git commit -m "commit for deploy to heroku"
#        git push -f heroku
#        
#    Visit store online:
#        http://warm-beach-63.heroku.com


Run f2n SERVER
---------------
f2n Server is a Java and OpenFire application that will run on the customer's
machine.

    Get folders from Subversion, including src, test, and keys folders.
        svn co https://cozybit.svn.cvsdude.com/face2name
    
    Make certificates -- For testing make your own. For production, use the keys in {svn}/keys.
        cd .../face2name/keys/ca
        openssl ???
    
    Run Extract script
        cd .../face2name/tests/openfire
        ./extract.sh --ssl-ca-cert ../../keys/ca/f2n_ca.crt --ssl-ca-key ../../keys/ca/f2n_ca.key.unsecure --admin-pw admin
        for winston:
        ./extract.sh --ssl-ca-cert ../../ww_keys/ca/f2n_ca.crt --ssl-ca-key ../../ww_keys/ca/f2n_ca.key.unsecure --admin-pw admin

    Manually copy Config Import keys
        cd {svn}/face2name/keys/config_bundles
        mkdir ../../tests/openfire/test_server/keys/config_bundle
        (note the "S" is omitted on the test_server directory)
        cp *.key ../../tests/openfire/test_server/keys/config_bundle/
    
    Run the server
        cd {svn}/face2name/tests/openfire/test_server/bin/
        (Note that current directory must be 'bin' folder.)
        ./openfire.sh
        (open browser to http://localhost:9080 )
    
    