source $ZSH_RECENTS/util_functions.zsh

# Wrapper to integrate "recents.zsh"
# TODO add the folder we are currently in, to the recents list before the one 
# we are cd'ing into
cd() {
  builtin cd $@ || { return 1; }

  addToRecents $(pwd)
  [ -z $1 ] && addToRecents $HOME
  addToRecents $@
}

cp() {
  /bin/cp $@ || { return 1; }

  local destination=$(get_last_dirname_from_array $@)
  local oldFilenames=()
  local oldFilesDirnames=()

  if [[ -d $destination ]];
  then
    for arg in $@
    do
      oldFilenames+=$(basename $arg 2> /dev/null)
      [[ $(realpath "$arg" 2> /dev/null) == $(realpath $destination) ]] && continue
      oldFilesDirnames+=$(dirname $arg 2> /dev/null)
    done

    local newFilenames=()

    for filename in $oldFilenames
    do
      newFilenames+="$destination/$filename"
    done

    addToRecents $oldFilenames $newFilenames $oldFilesDirnames $destination
  fi
}

# Wrapper for zsh module "recent files and dirs"
mv() {
  /bin/mv $@

  # TODO Make this if statement shorter/merge with rest of function
  if [ $# -eq 2 ]; then
    if [ -d $(realpath $2) ]; then
      /bin/mv $@ && [[ $? -eq 1 ]] && exit;
      local filename=$(basename $1)
      local oldDirname=$(dirname $1)
      local filenameWithDirName="$2/$filename"
      addToRecents $oldDirname $filenameWithDirName
    else;
      /bin/mv $@
      local oldDirname=$(dirname $1)
      addToRecents $oldDirname $*[1]
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

  addToRecents $oldFilesDirs $newFiles
}

