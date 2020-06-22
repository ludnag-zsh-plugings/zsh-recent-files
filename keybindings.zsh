zsh_recents_list_recent_dirs_cd() {
setopt SH_WORD_SPLIT # ??
local selected

  # Stop if there are no recent entries
  [[ $(wc -l $recent_dirs | awk '{ print $1;}') -eq 0 ]] && echo "\nNo recent dirs.\n\n" && zle fzf-redraw-prompt && return 1;

  if selected=$(tac $recent_dirs | sed "s,$HOME,~,; s,$,/,; s,//,/," | fzf --header "CD to recently used dir" --no-sort); then
    selected=$(tr '\n' ' ' <<< ${selected}) # replace newlines with spaces
    selected=$(sed "s,~,$HOME," <<< ${selected})
    selected=$(echo $selected | rev | cut -c1- | rev )
    cd "${selected}"
    add_to_recents $selected
  else
    return 1;
  fi
  zle reset-prompt # re-renders the prompt

  first_char_selected=$(echo $selected | cut -c 1)
  if [ $first_char_selected = "~" ];
  then
    rp_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  else
    rp_selected=$selected
  fi

  (add_to_recents $rp_selected &) > /dev/null
}
zle -N zsh_recents_list_recent_dirs_cd
#bindkey '^d' fzf-list-recent-dirs-cd

zsh_recents_list_recent_dirs_insert() {
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
    rp_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  else
    rp_selected=$selected
  fi

  (add_to_recents $rp_selected &) > /dev/null
}
zle -N zsh_recents_list_recent_dirs_insert
bindkey '^d' zsh_recents_list_recent_dirs_insert

zsh_recents_list_recent_files_insert() {
  local selected
  setopt SH_WORD_SPLIT

  [[ $(wc -l $recent_files | awk '{ print $1;}') -eq 0 ]] && echo "\nNo recent files.\n\n" && zle fzf-redraw-prompt && return 1;

  if selected=$(tac $recent_files | sed "s,$HOME,~,; s,//,/," | fzf --header "Add recently used FILENAMES to prompt" --height=40%  --no-sort); then
    selected=$(tr '\n' ' ' <<< ${selected}) # replace newlines with spaces
    LBUFFER="$LBUFFER$selected"
    zle reset-prompt
    zle fzf-redraw-prompt #clear the prompt of any potential error messages
  else

    return 1;
  fi

  first_char_selected=$(echo $selected | cut -c 1)
  if [ $first_char_selected = "~" ];
  then
    rp_selected="$(echo ${HOME}$(echo ${selected} | cut -c 2-))"
  else
    rp_selected=$selected
  fi

  (add_to_recents $rp_selected &) > /dev/null
}
zle -N zsh_recents_list_recent_files_insert
bindkey '^f' zsh_recents_list_recent_files_insert
