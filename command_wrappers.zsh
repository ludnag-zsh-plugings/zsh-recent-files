source $ZSH_RECENTS/util_functions.zsh

# TODO For all wrappers: add paths to be added to recents to an array 
# throughout the functions. Then, at the end, add all the entries in the array 
# to recents. Should be more readable

cd() {
  local orig_dir="$(pwd)"
  local dest=""
  [[ ! -z $@ ]] && local dest=$(realpath $@)
  builtin cd "$@" || { return 1; }

  ( [[ -z $1 ]] && dest="$HOME"
  add_to_recents $orig_dir $dest &) > /dev/null
}

cp() {
  /bin/cp $@ || { return 1; }

  ( local destination=$(get_last_dirname_from_array $@)
  local old_basenames=()
  local new_filepaths=()

  if [[ -d $destination ]];
  then
    for arg in $@
    do
      [[ $(realpath $arg 2> /dev/null) == $(realpath $destination) ]] && continue
      old_basenames+=$(basename $arg 2> /dev/null)
    done

    for old_basename in $old_basenames
    do
      new_filepaths+="$destination/$old_basename"
    done
  fi

  add_to_recents $new_filepaths $@ &) > /dev/null
}

# Wrapper for zsh module "recent files and dirs"
mv() {
  /bin/mv "$@" || { return 1; }

  # TODO Make this if statement shorter/merge with rest of function
  if [ $# -eq 2 ]; then
    if [ -d $(realpath $2) ]; then
      local old_basename=$(basename "$1")
      local old_dirname=$(dirname "$1")
      local filename_withdir_name="$2/$old_basename"
      add_to_recents "$old_dirname" "$filename_withdir_name"
    else;
      local old_dirname=$(dirname $1)
      add_to_recents $old_dirname $@[1]
    fi
    return 0
  fi

  old_files_dirs=()

  for arg in $@;
  do
    [[ -f $arg ]] && old_files_dirs+=$(dirname $arg)
  done

  new_files=()
  destination_dir=${@:~0}

  for arg in $@;
  do
    potential_new_filename="$destination_dir/$arg"
    [[ -f "$potential_new_filename" ]] && new_files+=$potential_new_filename
  done

  add_to_recents $old_files_dirs $new_files "$@"
}

v() {
  $EDITOR $@

  (add_to_recents $@ &) > /dev/null
}

