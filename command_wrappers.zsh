source $ZSH_RECENTS/util_functions.zsh

# Wrapper to integrate "recents.zsh"
# TODO add the folder we are currently in, to the recents list before the one 
# we are cd'ing into
cd() {
  local orig_dir="$(pwd)"
  local dest=""
  [[ ! -z $@ ]] && local dest=$(realpath $@)
  builtin cd "$@" || { return 1; }

  ( addToRecents $(pwd)
  [[ -z $1 ]] && addToRecents $HOME
  addToRecents $orig_dir $dest &) > /dev/null
}

cp() {
  /bin/cp $@ || { return 1; }

  ( local destination=$(get_last_dirname_from_array $@)
  local oldBasenames=()
  local newFilepaths=()

  if [[ -d $destination ]];
  then
    for arg in $@
    do
      [[ $(realpath "$arg" 2> /dev/null) == $(realpath $destination) ]] && continue
      oldBasenames+=$(basename $arg 2> /dev/null)
    done

    for oldBasename in $oldBasenames
    do
      newFilepaths+="$destination/$oldBasename"
    done
  fi

    #addToRecents $oldBasenames $newFilepaths $oldFilesDirnames $destination
    addToRecents $newFilepaths $@ &) > /dev/null
}

# Wrapper for zsh module "recent files and dirs"
mv() {
  /bin/mv "$@" || { return 1; }

  # TODO Make this if statement shorter/merge with rest of function
  if [ $# -eq 2 ]; then
    if [ -d $(realpath $2) ]; then
      local oldBasename=$(basename "$1")
      local oldDirname=$(dirname "$1")
      local filenameWithDirName="$2/$oldBasename"
      addToRecents "$oldDirname" "$filenameWithDirName"
    else;
      local oldDirname=$(dirname $1)
      addToRecents $oldDirname $@[1]
    fi
    return 0
  fi

  oldFilesDirs=()

  for arg in $@;
  do
    [[ -f $arg ]] && oldFilesDirs+=$(dirname $arg)
  done

  newFiles=()
  destinationDir=${@:~0}

  for arg in $@;
  do
    potentialNewFilename="$destinationDir/$arg"
    [[ -f "$potentialNewFilename" ]] && newFiles+=$potentialNewFilename
  done

  addToRecents $oldFilesDirs $newFiles "$@"
}

