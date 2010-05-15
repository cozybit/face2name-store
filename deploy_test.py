#!/usr/bin/env python

'''
Deploy to a test app on Heroku.

First time it will setup Git locallay and create a Heroku App.
After that, it will update Heroku.
'''
import sys
import os
import os.path as op
import shutil

sys.path.append( '../deploy')
import deploy

from deploy import call, bold, info, error    # i.e. ../deploy/deploy.py

THIS_DIR = op.dirname( __file__ )


def clean_git():
    bold( 'Deleting local GIT repository.')
    if raw_input('Type "yes" if you are sure you want to delete the local git repository: ')!='yes':
        bold( 'Cancelled.')
        return
    shutil.rmtree( op.join( THIS_DIR, '.git'))

    
def create_git_and_heroku_app():
    bold('Creating a local GIT repository.')
    call('git init')
    output = call('heroku create')
    print
    

def step_1():

    bold('Checking Prerequisites')
    call('git --version', error_msg='GIT is not installed.')
    call('svn --version --quiet', error_msg='Subversion is not installed.')
    call('heroku version', error_msg='Heroku is not installed.')

    # Is this the first time?
    if not op.exists('.git'):
        create_git_and_heroku_app()
        done_msg = '''
-----------------------------------------------------------------------------
You are creating a Heroku app for the first time. Please check the list
of files above, and possible fix them using "git add/rm". When ready
run:
    ./deploy_test.py create_heroku
-----------------------------------------------------------------------------
'''
        
    else:
        done_msg = '''
-----------------------------------------------------------------------------
Above are the changes since your last deployment. Please check them.
Be careful with "git add *" since private face2name keys are not stored 
in Subversion, i.e.: lib/f2n_ca.key.unsecure

When "git status" looks correct, run step two to commit and deploy by
typing: 
    ./deploy_test.py step_2
-----------------------------------------------------------------------------
'''
    call('git add *')
    call('git status')

    bold( done_msg )

def create_heroku():
    bold('Pushing files to Heroku')

    commit_msg = 'Subversion rev '+call('svnversion .' ).strip()
    call('git commit -m "{commit_msg}"'.format(commit_msg=commit_msg), ignore_exit_code=True)

    bold('Creating a new app at Heroku.')
    call('heroku create' )
    call('heroku stack:migrate bamboo-ree-1.8.7')

    call('git push heroku master')

    bold('Migrating database at Heroku')
    call('heroku rake db:migrate' )
    
    bold('''
------------------------------------------------------------------------
Done. Type "heroku info" to see where your new heroku application is.
------------------------------------------------------------------------
''')
    
def step_2():
    deploy.step_2('.')


#
#   Command processing
#

if __name__=='__main__':
    
    
    try:

        # Available commands = any functions except starting with underline
        avail_cmds = ( 'step_1','step_2', 'create_heroku', 'clean_git' )
    
        # Run the function indicated on the command line.
        if len(sys.argv) >= 2:
            cmd_name = sys.argv[1]
        else:
            cmd_name = 'step_1'
        assert cmd_name in avail_cmds, "User's command is not one of the available commands: %s"\
                %', '.join(avail_cmds)

        os.chdir( THIS_DIR )
        bold('Running',cmd_name)
        vars()[ cmd_name ]() # find the function and run it.
            
    except RuntimeError, exc:
        error(exc)
        raise
        