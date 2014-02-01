#! /bin/bash

function usage {
  echo "Usage: deploy.sh [web or game]"
  exit 1
}

if [[ $1 != 'web' && $1 != 'game' ]]; then
  usage
elif [[ -z $1 ]]; then
  usage
else
  ENV=$1
fi

UNSTAGED_CHANGES=$( git diff --exit-code )
STAGED_CHANGES=$( git diff --cached --exit-code )
ROOT=$( git rev-parse --show-toplevel )
BRANCH=$( git rev-parse --abbrev-ref HEAD )
HASH=$( git rev-parse HEAD )

REMOTE_CHECK=$( git remote -v | grep $ENV )
if [[ "$?" -eq 1 ]]; then
  echo "Doh. No remote for $ENV, you must add it first."
  echo
  echo "git remote add $ENV git@heroku.com:APPNAME.git"
  echo
  exit 1
fi

HEROKU_APP=$( git remote -v | grep $ENV | head -1 | sed -e "s/^.*\://" -e "s/\..*$//" )

if [[ $BRANCH == 'deploy' ]]; then
  echo "Are you sure you want to push the deploy branch?"
  read -p "Press [Enter] to push anyway..."
fi

if [[ -z $UNSTAGED_CHANGES && -z $STAGED_CHANGES ]]; then

  # Exit on any command failure
  set -e

  cd $ROOT
  echo "=== Checking out deploy branch"
  git checkout -B deploy

  echo "=== Copying Gemfile & Procfile"
  if [[ $ENV = 'web' ]]; then
    cp web_server/Gemfile Gemfile
    cp web_server/Gemfile.lock Gemfile.lock
    cp web_server/Procfile Procfile
  else
    cp game_server/Gemfile Gemfile
    cp game_server/Gemfile.lock Gemfile.lock
    cp game_server/Procfile Procfile
  fi

  git add -f Gemfile Gemfile.lock Procfile
  git commit -m 'Adding deploy files'

  echo "=== Merging $BRANCH into deploy"
  git merge $BRANCH --no-edit

  echo "=== Pushing to $ENV"
  git push -f $ENV deploy:master
  git checkout -

  echo "=== All done! Have a nice day :)"

else
  [[ -z $STAGED_CHANGES ]]   && echo "There are pending, unstaged changes"
  [[ -z $UNSTAGED_CHANGES ]] && echo "There are pending, staged changes"
  exit 1
fi
