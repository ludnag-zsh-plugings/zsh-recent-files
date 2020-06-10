# TODO there is some bug with underscores?
export recents="$HOME/.local/share/recents/"
export recentFiles="${recents}recent-files.txt"
export recentDirs="${recents}recent-dirs.txt" # Wrote these lines last time
export maxRecentsEntries=250
addToRecents() {
  local foundFiles=0
  local foundDirs=0

  [[ ! -d $recents ]] && mkdir -p $recents
  [[ ! -f $recentFiles ]] && touch $recentFiles
  [[ ! -f $recentDirs ]] && touch $recentDirs

  for arg in $*;
  do
    fullPathName=$(realpath $arg)
    [[ -f $fullPathName ]] && echo $fullPathName >> $recentFiles && echo $(realpath $(dirname $arg)) >> $recentDirs && let foundFiles++ foundDirs++
    [[ -d $fullPathName ]] && echo $fullPathName >> $recentDirs && let foundDirs++
  done

  # Remove duplicates
  if [ $foundFiles -gt 0 ]; then
    sed -i '/^$/d' $recentDirs
    tempRecentFiles=$recents/tempRecentFiles
    /bin/cp -f $recentFiles $tempRecentFiles
    tac $tempRecentFiles | awk '!x[$0]++' | tac > $recentFiles
    /bin/rm $tempRecentFiles
  fi

  if [ $foundDirs -gt 0 ]; then
    sed -i '/^$/d' $recentDirs
    tempRecentDirs=$recents/tempRecentDirs
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

  # Trim recents history if it gets too long
  [[ $(wc -l $recentFiles | awk '{ print $1;}') -gt $maxRecentsEntries ]] && tac $recentFiles | head -$maxRecentsEntries | tac > $tempRecentFiles && /bin/mv $tempRecentFiles $recentFiles
  [[ $(wc -l $recentDirs | awk '{ print $1;}') -gt $maxRecentsEntries ]] && echo "Too many entries!!" && tac $recentDirs | head -$maxRecentsEntries | tac > $tempRecentDirs && /bin/mv $tempRecentDirs $recentDirs
}
