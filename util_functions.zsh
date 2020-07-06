# Updating prompt if the previous command changed the branch
fzf_redraw_prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf_redraw_prompt

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
