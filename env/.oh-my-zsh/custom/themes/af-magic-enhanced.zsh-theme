# af-magic-enhanced.zsh-theme
#
# Enhanced version of af-magic with better readability for dark themes
# Based on af-magic by Andy Fleming
# Optimized for: compact, no emojis, readable text, dark themes

# dashed separator size
function afmagic_dashes {
  # check either virtualenv or condaenv variables
  local python_env_dir="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"
  local python_env="${python_env_dir##*/}"

  # if there is a python virtual environment and it is displayed in
  # the prompt, account for it when returning the number of dashes
  if [[ -n "$python_env" && "$PS1" = *\(${python_env}\)* ]]; then
    echo $(( COLUMNS - ${#python_env} - 3 ))
  elif [[ -n "$VIRTUAL_ENV_PROMPT" && "$PS1" = *${VIRTUAL_ENV_PROMPT}* ]]; then
    echo $(( COLUMNS - ${#VIRTUAL_ENV_PROMPT} - 3 ))
  else
    echo $COLUMNS
  fi
}

# primary prompt: dashed separator, directory and vcs info
# Enhanced colors for better readability:
# - Separator: slightly brighter gray (244 instead of 237)
# - Directory: bright green (046 instead of 032) 
# - Prompt symbol: bright magenta (201 instead of 105)
PS1="${FG[244]}\${(l.\$(afmagic_dashes)..-.)}%{$reset_color%}
${FG[046]}%~\$(git_prompt_info)\$(hg_prompt_info) ${FG[201]}%(!.#.»)%{$reset_color%} "
PS2="%{$fg[red]%}\ %{$reset_color%}"

# right prompt: return code, virtualenv and context (user only)
# Enhanced: brighter user (250 instead of 237 for much better readability)
RPS1="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
if (( $+functions[virtualenv_prompt_info] )); then
  RPS1+='$(virtualenv_prompt_info)'
fi
RPS1+=" ${FG[250]}%n%{$reset_color%}"

# git settings - enhanced colors for better visibility
# Branch name: bright cyan (087 instead of 078)
# Parentheses: bright blue (081 instead of 075)
ZSH_THEME_GIT_PROMPT_PREFIX=" ${FG[081]}(${FG[087]}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${FG[081]})%{$reset_color%}"

# hg settings - enhanced colors
ZSH_THEME_HG_PROMPT_PREFIX=" ${FG[081]}(${FG[087]}"
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY="${FG[214]}*%{$reset_color%}"
ZSH_THEME_HG_PROMPT_SUFFIX="${FG[081]})%{$reset_color%}"

# virtualenv settings - enhanced colors
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[081]}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"
