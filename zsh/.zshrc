# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY      # store timestamps and durations
setopt HIST_FIND_NO_DUPS     # don't show duplicates while searching
setopt HIST_IGNORE_ALL_DUPS  # keep only the newest copy of a repeated command
setopt HIST_IGNORE_SPACE     # a leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY           # show history expansion before running it
setopt SHARE_HISTORY         # write as you type, so concurrent panes share history

# ergonomics
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

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
alias ocm="opencode mini --model opencode-go/deepseek-v4.1-flash"
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
