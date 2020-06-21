# TODO there is some bug with underscores?
export ZSH_RECENTS_DATA="$HOME/.local/share/zsh/zsh_recents/"

recent_files="${ZSH_RECENTS_DATA}recent_files.txt"
recent_dirs="${ZSH_RECENTS_DATA}recent_dirs.txt"

max_recents_entries=250

add_to_recents() {
  local found_files=0
  local found_dirs=0

  [[ ! -d $ZSH_RECENTS_DATA ]] && mkdir -p $ZSH_RECENTS_DATA
  [[ ! -f $recent_files ]] && touch $recent_files
  [[ ! -f $recent_dirs ]] && touch $recent_dirs

  for arg in $@;
  do
    full_pathname=$(realpath $arg)
    [[ -f $full_pathname ]] && echo $full_pathname >> $recent_files && echo $(realpath $(dirname $arg)) >> $recent_dirs && let found_files++ found_dirs++
    [[ -d $full_pathname ]] && echo $full_pathname >> $recent_dirs && let found_dirs++
  done

  # Remove duplicates
  if [ $found_files -gt 0 ]; then
    sed -i '/^$/d' $recent_dirs
    temp_recent_files=$ZSH_RECENTS_DATA/temp_recent_files
    /bin/cp -f $recent_files $temp_recent_files
    tac $temp_recent_files | awk '!x[$0]++' | tac > $recent_files
    /bin/rm $temp_recent_files
  fi

  if [ $found_dirs -gt 0 ]; then
    sed -i '/^$/d' $recent_dirs
    temp_recent_dirs=$ZSH_RECENTS_DATA/temp_recent_dirs
    /bin/cp -f $recent_dirs $temp_recent_dirs
    tac $temp_recent_dirs | awk '!x[$0]++' | tac > $recent_dirs
    /bin/rm $temp_recent_dirs
  fi

  # Remove invalid paths
  for filename in $(cat $recent_files);
  do
    [[ ! -f $filename ]] && sed -i "\,$filename,d" $recent_files
  done

  for dirname in $(cat $recent_dirs);
  do
    [[ ! -d $dirname ]] && sed -i "\,$dirname,d" $recent_dirs
  done

  # Trim ZSH_RECENTS_DATA history if it gets too long
  [[ $(wc -l $recent_files | awk '{ print $1;}') -gt $max_recents_entries ]] && tac $recent_files | head -$max_recents_entries | tac > $temp_recent_files && /bin/mv $temp_recent_files $recent_files
  [[ $(wc -l $recent_dirs | awk '{ print $1;}') -gt $max_recents_entries ]] && echo "Too many entries!!" && tac $recent_dirs | head -$max_recents_entries | tac > $temp_recent_dirs && /bin/mv $temp_recent_dirs $recent_dirs
}
