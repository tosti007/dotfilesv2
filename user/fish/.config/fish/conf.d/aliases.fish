# Command overwrites and shortcuts
alias rmr "rm -rf"
alias xclip "xclip -selection clipboard"

# ls shortcuts, but with exa because that's cooler
alias ls "exa --group-directories-first"
alias ll "ls -l"
alias la "ll -a"
alias tree "ls --tree"

# cat shortcuts, but with bat
alias cat "bat"
alias ccat "bat --plain --color never --pager never"
alias rgpdf "rg --pre $HOME/.dotfiles/assets/rgpdf-pre.sh --pre-glob '*.pdf'"

# git aliases
alias gis "git status"
alias gid "git diff"
alias gia "git add"
alias gic "git commit -m"
alias gip "git pull --rebase"
alias giu "git push"
alias gir "git reset"

