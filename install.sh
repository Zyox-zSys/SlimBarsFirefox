#!/bin/sh

# Config
FIREFOX="$HOME/.mozilla/firefox"
USERCHROME="$(pwd)/userChrome.css"


# Functions

function fetchProfile {
  # Fetch current profile from $FIREFOX/profiles.ini
  #   via reading the first "Default" key
  PROFILE=$(grep -m1 -oP "(?<=Default=).*" ./profiles.ini)
  
  if [ -z $PROFILE ]; then
    # If not found, fetch latest modified; "./*/" finds directories
    #   -A, --almost-all           do not list implied . and ..
    #   -t                         sort by time, newest first; see --time
    #   -r, --reverse              reverse order while sorting
    #   -d, --directory            list directories themselves, not their contents
    PROFILE=$(ls -Atrd "./*/" | tail -1)
  fi

  echo "$FIREFOX/$PROFILE"
}

function appendUserChrome {
  # Enable customization via userChrome.css if disabled
  touch "$1/prefs.js"
  if [ -z $(grep -P "legacyUserProfileCustomizations*?true" $1/prefs.js) ]; then
    echo "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);" >> "$1/prefs.js"
  fi
  
  # Append
  touch "$1/chrome"
  ucFile="$1/chrome/userChrome.css"
  touch "$ucFile"
  cat "$USERCHROME" >> "$ucFile"
  echo "userChrome.css appended to $ucFile"
}


# Run

function main {
  cd "$FIREFOX"
  appendUserChrome $(fetchProfile)
}
main
