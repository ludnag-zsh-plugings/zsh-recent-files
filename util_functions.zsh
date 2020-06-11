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
