
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
  #! /bin/cp $* && return
  /bin/cp $*

  local destination=${@:~0}
  #echo destination:$destination

  if [[ -f $destination ]];
  then
    #echo "\$destination is a file"
    addToRecents $1 $destination
  else;
    local oldFilenames=()
    for arg in $*
    do
      #echo arg: $arg
      oldFilenames+=$(basename $arg &> /dev/null)
    done

    local newFilenames=()

    for oldFilename in $oldFilenames
    do
      #echo before: $oldFilename
      newFilenames+="$destination/$oldFilename"
      #echo after: ${newFilenames:~0} 
    done
    addToRecents $oldFilenames $newFilenames
  fi

}
