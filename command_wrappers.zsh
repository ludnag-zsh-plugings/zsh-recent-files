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
  old_files_dirnames=()

  for arg in $@;
  do
    [[ -f $arg ]] && old_files_dirnames+=$(dirname $arg)
  done

  /bin/mv -i "$@" || { return 1; }


  (new_files=()
  destination_dir=${@:~0}

  for arg in $@;
  do
    potential_new_filename="$destination_dir/$arg"
    [[ -f "$potential_new_filename" ]] && new_files+=$potential_new_filename
  done

  add_to_recents $old_files_dirnames $new_files "$@") > /dev/null
}

v() {
  $EDITOR $@

  (add_to_recents $@ &) > /dev/null
}

