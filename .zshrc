#!/usr/bin/env bash
# shellcheck disable=SC1071,SC1090


# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="ys"
export plugins=(git)

export HIST_STAMPS="+%Y-%m-%d %T"

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi


# direnv
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi


# Kubernetes
alias k=kubectl
if command -v kubectl > /dev/null; then
    source <(kubectl completion zsh)
fi


# Poetry
export PATH="$HOME/.poetry/bin:$PATH"


# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv > /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi
