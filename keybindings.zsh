zsh_recents_cd() {
setopt SH_WORD_SPLIT # ??
local selected

  # Stop if there are no recent entries
  [[ $(wc -l $recent_dirs | awk '{ print $1;}') -eq 0 ]] && echo "\nNo recent dirs.\n\n" && zle fzf-redraw-prompt && return 1;

  if selected=$(tac $recent_dirs | sed "s,$HOME,~,; s,$,/,; s,//,/," | fzf --header "CD to recently used dir" --height=40% --no-sort); then

    selected=$(tr '\n' ' ' <<< ${selected}) # replace newlines with spaces
    selected=$(sed "s,~,$HOME," <<< ${selected})
    selected=$(echo $selected | rev | cut -c1- | rev )
    cd "${selected}"
  else
    return 1;
  fi

  zle reset-prompt # re-renders the prompt after noninteractive cd

  #first_char_selected=$(echo $selected | cut -c 1)
  #if [ $first_char_selected = "~" ];
  #then
    #realpath_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  #else
    #realpath_selected=$selected
  #fi

  #(add_to_recents $realpath_selected &) > /dev/null
}
zle -N zsh_recents_cd
bindkey '^t' zsh_recents_cd

zsh_recents_insert_recent_dirs() {
  setopt SH_WORD_SPLIT
  local selected

  [[ $(wc -l $recent_dirs | awk '{ print $1;}') -eq 0 ]] && echo "\nNo recent dirs.\n\n" && zle fzf-redraw-prompt && return 1;

  if selected=$(tac $recent_dirs | sed "s,$HOME,~,; s,$,/,; s,//,/," | fzf --header "Add recently used DIRNAMES to prompt" --height=40% --no-sort); then
    selected=$(tr '\n' ' ' <<< ${selected}) # replace newlines with spaces
    LBUFFER="$LBUFFER$selected"
    zle reset-prompt
    zle fzf-redraw-prompt #clear the prompt of any potential error messages
  else
    zle fzf-redraw-prompt #clear the prompt of any potential error messages
    return 1;
  fi

  first_char_selected=$(echo $selected | cut -c 1)
  if [ $first_char_selected = "~" ];
  then
    realpath_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  else
    realpath_selected=$selected
  fi

  echo "" # prevent deleting previous line in prompt
  echo "" # prevent deleting previous line in prompt

  (add_to_recents $realpath_selected &) > /dev/null
}
zle -N zsh_recents_insert_recent_dirs
bindkey '^d' zsh_recents_insert_recent_dirs

zsh_recents_insert_recent_files() {
  local selected
  setopt SH_WORD_SPLIT

  [[ $(wc -l $recent_files | awk '{ print $1;}') -eq 0 ]] && echo "\nNo recent files.\n\n" && zle fzf-redraw-prompt && return 1;

  if selected=$(tac $recent_files | sed "s,$HOME,~,; s,//,/," | fzf --header "Add recently used FILENAMES to prompt" --height=40%  --no-sort); then
    selected=$(tr '\n' ' ' <<< ${selected}) # replace newlines with spaces
    LBUFFER="$LBUFFER$selected"
    zle reset-prompt
    zle fzf-redraw-prompt #clear the prompt of any potential error messages
  else
    zle fzf-redraw-prompt #clear the prompt of any potential error messages
    return 1;
  fi

  echo "" # prevent deleting previous line in prompt
  echo "" # prevent deleting previous line in prompt

  first_char_selected=$(echo $selected | cut -c 1)
  if [ $first_char_selected = "~" ];
  then
    realpath_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  else
    realpath_selected=$selected
  fi

  (add_to_recents $realpath_selected &) > /dev/null
}
zle -N zsh_recents_insert_recent_files
bindkey '^f' zsh_recents_insert_recent_files
