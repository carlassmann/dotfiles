fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(mise activate zsh)"
source <(fzf --zsh)

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
command -v work >/dev/null && eval "$(work shell-init zsh)"
[ -f "$HOME/.config/op/plugins.sh" ] && source "$HOME/.config/op/plugins.sh"

alias l="ls -lah"
alias lg="lazygit"
alias ld="lazydocker"
alias oc="opencode"
alias reload="source ~/.zshrc"
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."
alias p="cd ~/Developer"
alias prx="pr-review"
alias path='echo $PATH | tr ":" "\n"'

if [[ "$OSTYPE" == darwin* ]]; then
  alias cpwd="pwd | pbcopy"
else
  alias cpwd="pwd | wl-copy"
  alias open="xdg-open"
fi
