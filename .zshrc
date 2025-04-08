# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set starting directory to home
cd /home/shannon

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme - keeping Powerlevel10k but we'll make it simpler!
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
plugins=(
    git
    docker
    ansible
    terraform
    kubectl
    python
    z
    fzf
    tmux
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Fix for Docker completions
if [[ ! -f /usr/share/zsh/vendor-completions/_docker ]]; then
  if [[ -f /usr/local/share/zsh/site-functions/_docker ]]; then
    sudo mkdir -p /usr/share/zsh/vendor-completions
    sudo ln -sf /usr/local/share/zsh/site-functions/_docker /usr/share/zsh/vendor-completions/_docker
  elif [[ -f ~/.oh-my-zsh/plugins/docker/_docker ]]; then
    sudo mkdir -p /usr/share/zsh/vendor-completions
    sudo ln -sf ~/.oh-my-zsh/plugins/docker/_docker /usr/share/zsh/vendor-completions/_docker
  fi
fi

# Python uv setup
if command -v uv &> /dev/null; then
  eval "$(uv --completion-shell zsh)"
  alias pip='uv pip'  # Replace pip with uv pip
  alias uvenv='uv venv'  # Create virtual environments
fi

# User configuration

# Set personal aliases - like shortcuts for your favorite toys!
alias ll='ls -lsha'
alias gs='git status'
alias gp='git pull'
alias gc='git commit -m'
alias k='kubectl'
alias tf='terraform'
alias k='kubectl'
alias tf='terraform'
alias g='git'
alias py='python'
alias ipy='ipython'

# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'

# Enhanced kubectl aliases
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kaf='kubectl apply -f'

# Tmux aliases
alias tn='tmux new -s'  # Create new session with name
alias ta='tmux attach -t'  # Attach to session
alias tl='tmux list-sessions'  # List sessions
alias tk='tmux kill-session -t'  # Kill session

# Quick folder navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Optimize Zsh history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Prevent duplicates in history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history
setopt extended_history

# Enable better tab completion
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Make FZF super fast for searching history!
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

# Bind Ctrl+R to fzf history search - find your commands super fast!
if command -v fzf > /dev/null 2>&1; then
    [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
    [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
fi

# Use vim keys in tab completion menu (if you know vim!)
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Auto start tmux if installed
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
fi

# Make VS Code use zsh as default
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='code'
fi

# Additional path for Python and other tools
export PATH=$HOME/.local/bin:$PATH

# Node Version Manager setup for Full Stack development
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Python virtual environment support
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
