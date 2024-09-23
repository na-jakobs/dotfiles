# Settings
setopt auto_cd
setopt pushdsilent
setopt autopushd
setopt extended_glob

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${ZDOTDIR}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${ZDOTDIR}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ${HOME}/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit ice wait"2" # load after 2 seconds
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit snippet OMZP::git

# Docker
#export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Brew
export HOMEBREW_NO_ENV_HINTS=true
eval "$(/opt/homebrew/bin/brew shellenv)"
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# vi mode is enabled by default when EDITOR is set to 'vim'
# this changes the keymaps back to emacs mode
bindkey "^A" vi-beginning-of-line
bindkey "^E" vi-end-of-line

# lang
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# pipx
export PATH="$PATH:$HOME/.local/bin"

# z
eval "$(zoxide init zsh)"

# disable up-arrow for atuin
#bindkey "^[[A" history-beginning-search-backward # after the atuin init

# bat
export BAT_THEME="Dracula"

# subl
export PATH="$HOME/bin:/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# pipx venv
export PATH="$HOME/.local/bin:$PATH"

# go bin
export PATH="$HOME/go/bin:$PATH"
export GOBIN="$HOME/go/bin"

# gnu getopt
export PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"

# gnu tar
export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"

# gnu grep
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# add ssh keys if needed
#[[ ! -z ${SSH_AGENT_PID+x} ]] && eval $(ssh-agent -s) &> /dev/null 
#[[ -z ${SSH_AGENT_PID+x} ]] && eval $(ssh-agent -s) 
# if [[ $(pgrep -u "$USER" ssh-agent &> /dev/null) ]] ; then
#     eval $(ssh-agent -s)
# fi
if [[ $(pgrep -u "$USER" ssh-agent) ]] ; then
    #echo "not starting ssh-agent"
else
    echo "starting ssh-agent"
    eval $(ssh-agent -s)
fi
ssh-add -q ~/.ssh/id_ed25519
ssh-add -q ~/.ssh/id_ed25519_signing
ssh-add -q ~/.ssh/id_rsa

source $ZDOTDIR/.aliases
source $ZDOTDIR/.functions
source $ZDOTDIR/.tokens

# better autocomplete
#bindkey "^[[A" history-beginning-search-backward
#bindkey "^[[B" history-beginning-search-forward

# ---- FZF -----

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# Set up fzf key bindings and fuzzy completion
#eval "$(fzf --zsh)"
source <(fzf --zsh)

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source $HOME/bin/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

source $HOME/.config/zsh/.fzf-key-bindings.zsh

# gcloud
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# dotnet
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:/opt/homebrew/opt/dotnet@6/bin"

# Docker
export DOCKER_CLI_HINTS=false

# kubescape
export PATH=$PATH:$HOME/.kubescape/bin

autoload -U compinit
compinit -i
