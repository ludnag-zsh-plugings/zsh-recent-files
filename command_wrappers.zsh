
# Wrapper to integrate "recents.zsh"
# TODO add the folder we are currently in, to the recents list before the one 
# we are cd'ing into
cd() {
  addToRecents $(pwd)
  [ -z $1 ] && addToRecents $HOME
  addToRecents $*
  builtin cd $*
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

get_last_dirname_from_array() {
  last_dirname="";
  for arg in $@;
  do
    if [ -d $arg ]; then
      last_dirname=$arg
    fi
  done

  echo $last_dirname
}
