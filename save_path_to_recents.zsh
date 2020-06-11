# TODO there is some bug with underscores?
export ZSH_RECENTS_DATA="$HOME/.local/share/zsh/zsh_recent_files/"

recentFiles="${ZSH_RECENTS_DATA}recent-files.txt"
recentDirs="${ZSH_RECENTS_DATA}recent-dirs.txt" # Wrote these lines last time

maxRecentsEntries=250

addToRecents() {
  local foundFiles=0
  local foundDirs=0

  [[ ! -d $ZSH_RECENTS_DATA ]] && mkdir -p $ZSH_RECENTS_DATA
  [[ ! -f $recentFiles ]] && touch $recentFiles
  [[ ! -f $recentDirs ]] && touch $recentDirs

  for arg in $@;
  do
    fullPathname=$(realpath $arg)
    [[ -f $fullPathname ]] && echo $fullPathname >> $recentFiles && echo $(realpath $(dirname $arg)) >> $recentDirs && let foundFiles++ foundDirs++
    [[ -d $fullPathname ]] && echo $fullPathname >> $recentDirs && let foundDirs++
  done

  # Remove duplicates
  if [ $foundFiles -gt 0 ]; then
    sed -i '/^$/d' $recentDirs
    tempRecentFiles=$ZSH_RECENTS_DATA/tempRecentFiles
    /bin/cp -f $recentFiles $tempRecentFiles
    tac $tempRecentFiles | awk '!x[$0]++' | tac > $recentFiles
    /bin/rm $tempRecentFiles
  fi

  if [ $foundDirs -gt 0 ]; then
    sed -i '/^$/d' $recentDirs
    tempRecentDirs=$ZSH_RECENTS_DATA/tempRecentDirs
    /bin/cp -f $recentDirs $tempRecentDirs
    tac $tempRecentDirs | awk '!x[$0]++' | tac > $recentDirs
    /bin/rm $tempRecentDirs
  fi

  # Remove invalid paths
  for filename in $(cat $recentFiles);
  do
    [[ ! -f $filename ]] && sed -i "\,$filename,d" $recentFiles
  done

  for dirname in $(cat $recentDirs);
  do
    [[ ! -d $dirname ]] && sed -i "\,$dirname,d" $recentDirs
  done

  # Trim ZSH_RECENTS_DATA history if it gets too long
  [[ $(wc -l $recentFiles | awk '{ print $1;}') -gt $maxRecentsEntries ]] && tac $recentFiles | head -$maxRecentsEntries | tac > $tempRecentFiles && /bin/mv $tempRecentFiles $recentFiles
  [[ $(wc -l $recentDirs | awk '{ print $1;}') -gt $maxRecentsEntries ]] && echo "Too many entries!!" && tac $recentDirs | head -$maxRecentsEntries | tac > $tempRecentDirs && /bin/mv $tempRecentDirs $recentDirs
}
