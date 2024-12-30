# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
[ -r /home/steph/.byobu/prompt ] && . /home/steph/.byobu/prompt   #byobu-prompt#
. "$HOME/.cargo/env"


read_adapt_system_prompt() {
  # Définir les variables
  local CURRENT_TIME=$(date +"%H:%M:%S")
  local CURRENT_DATE="$(date +%A) $(date +%F)"
  local OS_NAME=$(uname -s)
  local OS_RELEASE=$(cat /etc/os-release | grep -v '^.*_URL=')
  local HOSTNAME=$(hostname)
  local IP_ADDRESS=$(hostname -I | awk '{print $1}')
  local TOP_HEAD=$(top -bn1 | head -n 5)
  local MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
  local DISK_USAGE=$(df -h / | awk 'NR==2{print $3"/"$2}')
  local CONNECTED_USERS=$(who | awk '{print $1}' | sort | uniq | paste -sd ',' -)

  # Lire le fichier de prompt
  local PROMPT_FILE="$HOME/.system_prompt.md"
  if [[ ! -f "$PROMPT_FILE" ]]; then
      echo "Le fichier de prompt $PROMPT_FILE n'existe pas."
      exit 1
  fi

  # Lire le contenu du fichier de prompt
  local PROMPT_CONTENT=$(<"$PROMPT_FILE")

  # Remplacer les placeholders par les valeurs des variables
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{CURRENT_TIME\}\}/$CURRENT_TIME}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{CURRENT_DATE\}\}/$CURRENT_DATE}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{OS_NAME\}\}/$OS_NAME}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{OS_RELEASE\}\}/$OS_RELEASE}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{HOSTNAME\}\}/$HOSTNAME}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{IP_ADDRESS\}\}/$IP_ADDRESS}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{TOP_HEAD\}\}/$TOP_HEAD}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{MEMORY_USAGE\}\}/$MEMORY_USAGE}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{DISK_USAGE\}\}/$DISK_USAGE}
  PROMPT_CONTENT=${PROMPT_CONTENT//\{\{CONNECTED_USERS\}\}/$CONNECTED_USERS}

  # Afficher le prompt final
  echo "$PROMPT_CONTENT"
}



qwen(){
  local concat=""
  for arg in "$@"; do
    result+="$arg "
  done
  # Supprimons l'espace final
  result=${result% }
  curl -s -X POST 127.0.0.1:11434/api/generate -H "Content-Type: application/json" -d "{\"model\":\"qwen2.5-coder:3b\",\"prompt\":\"$result\",\"stream\":false}" | jq -r '.response'
}

codeai(){
  # Parametres par defaut
  local MODEL="codestral-latest"
  local temperature=0.7
  local max_tokens=4096
  local PROMPT=""
  #local SYSTEM_PROMPT=$(cat ~/.system_prompt.md)
  local SYSTEM_PROMPT=$(read_adapt_system_prompt)
  local API_KEY="VOTRE CLEF API"

  
  # Analyser les arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model)
        MODEL="$2"
        shift 2
        ;;
      --max-tokens)
        # Validation que la valeur est un nombre entier
        if [[ "$2" =~ ^[0-9]+$ ]]; then
          max_tokens="$2"
        else
          echo "Erreur : --max-tokens doit etre un nombre entier" >&2
          return 1
        fi
        shift 2
        ;;
      --temp)
        # Validation que la valeur est un nombre entier
        if [[ "$2" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
          temperature="$2"
        else
          echo "Erreur : --temp doit etre un nombre decimal" >&2
          return 1
        fi
        shift 2
        ;;
      --api-key)
        API_KEY="$2"
        shift 2
        ;;
      --prompt|-p)
        PROMPT="$2"
        shift 2
        ;;
      --system|-s)
        SYSTEM_PROMPT="$2"
        shift 2
        ;;
      *)
        echo "Option invalide : $1" >&2
        return 1
        ;;
    esac
  done

  # Verification des arguments requis
  if [[ -z "$PROMPT" ]]; then
    echo "Erreur : Le prompt est requis (utilisez --prompt)" >&2
  fi


# Créer le payload JSON avec la structure spécifique
JSON_PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg system_prompt "$SYSTEM_PROMPT" \
  --arg user_message "$PROMPT" \
  '{
    model: $model,
    messages: [
      {
        role: "system",
        content: $system_prompt
      },
      {
        role: "user",
        content: $user_message
      }
    ]
  }')


#echo "Debug: API=$API_KEY"

  # Envoi de la requete a l'API Mistral
  local RESPONSE=$(curl -s -X POST https://codestral.mistral.ai/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$JSON_PAYLOAD")

  # Extraction de la reponse
  local CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

  # Gestion des erreurs
  if [[ "$CONTENT" == "null" ]]; then
    echo "Erreur lors de la communication avec l'API Mistral Codestral :" >&2
    echo "$RESPONSE" >&2
    return 1
  fi

  # Affichage du contenu
  echo "$CONTENT"
}
