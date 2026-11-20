# ~/.bashrc — my shell setup (Ubuntu, oh-my-bash)

# Only run in interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

# ══ oh-my-bash ══════════════════════════════════════════════
export OSH="$HOME/.oh-my-bash"
OSH_THEME=""
OMB_USE_SUDO=true
OMB_TERM_USE_TPUT=no
DISABLE_UNTRACKED_FILES_DIRTY="true"

completions=(git ssh)
aliases=(general)
plugins=(sudo progress colored-man-pages fzf zoxide)

source "$OSH/oh-my-bash.sh"
# ── Prompt customization ──
CWD_THEME_PROMPT_COLOR=28            # folder box
CLOCK_THEME_PROMPT_COLOR=99          # clock box
USER_INFO_THEME_PROMPT_COLOR=48      # username box
USER_INFO_THEME_PROMPT_COLOR_SUDO=87
SCM_THEME_PROMPT_CLEAN_COLOR=28      # git box, no changes
SCM_THEME_PROMPT_DIRTY_COLOR=55     # git box, unsaved changes
LAST_STATUS_THEME_PROMPT_COLOR=59   # shows when a command fails
POWERLINE_PROMPT_CHAR="❯"
THEME_CLOCK_FORMAT="%I:%M %p"
POWERLINE_LEFT_PROMPT="last_status scm cwd"
POWERLINE_RIGHT_PROMPT="clock user_info"
# ══ History ═════════════════════════════════════════════════
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ══ Shell behavior ══════════════════════════════════════════
shopt -s checkwinsize globstar cdspell autocd

# ══ Environment ═════════════════════════════════════════════
export EDITOR=nano
export VISUAL=nano
case ":$PATH:" in
  *":$HOME/.npm-global/bin:"*) ;;
  *) export PATH="$HOME/.npm-global/bin:$PATH" ;;
esac

have() { command -v "$1" >/dev/null 2>&1; }

# ══ Quick ═══════════════════════════════════════════════════
alias c='clear'
alias q='exit'
alias h='history | tail -50'
alias hs='history | grep -i'
alias reload='source ~/.bashrc && echo "bashrc reloaded"'
alias brc='$EDITOR ~/.bashrc'
alias ....='../..'
alias .....='../../..'

# ══ System updates ══════════════════════════════════════════
alias update='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias search='apt search'
alias upgradable='apt list --upgradable'
have snap    && alias snapup='sudo snap refresh'
have flatpak && alias flatup='flatpak update -y'

# ══ Navigation ══════════════════════════════════════════════
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias dl='cd ~/Downloads'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias install='sudo apt install'
# ══ Files & listing ═════════════════════════════════════════
if have eza; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
else
  alias ll='ls -lah --color=auto'
  alias la='ls -A --color=auto'
fi

if have batcat; then
  alias bat='batcat'
  alias cat='batcat --paging=never'
fi

have rg && alias grep='rg'

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'
alias mkdir='mkdir -pv'
alias df='df -h -x tmpfs -x squashfs'
alias du='du -h'
alias big='du -ah . 2>/dev/null | sort -rh | head -20'

# ══ System info ═════════════════════════════════════════════
alias mem='free -h'
alias cpu='lscpu | head -20'
alias temps='sensors 2>/dev/null || echo "install lm-sensors"'
alias topmem='ps aux --sort=-%mem | head -11'
alias topcpu='ps aux --sort=-%cpu | head -11'
alias sysinfo='hostnamectl; echo; uptime -p; echo; free -h; echo; df -h -x tmpfs -x squashfs'
alias jctl='journalctl -p 3 -xb'          # errors since last boot
alias failed='systemctl --failed'
alias sc='sudo systemctl'
alias scs='systemctl status'
have btop && alias top='btop'

# ══ Network ═════════════════════════════════════════════════
alias myip='curl -s ifconfig.me; echo'
alias localip="ip -4 -br addr | grep -v '^lo'"
alias ports='sudo ss -tulpn'
alias ping='ping -c 5'
alias dnscheck='resolvectl status | grep -A2 "DNS Servers"'
alias flushdns='sudo resolvectl flush-caches && echo "DNS cache flushed"'
alias hosts='sudo $EDITOR /etc/hosts'
alias sshc='$EDITOR ~/.ssh/config'

# ══ VPN ═════════════════════════════════════════════════════
if have tailscale; then
  alias tsup='sudo tailscale up'
  alias tsdown='sudo tailscale down'
  alias tss='tailscale status'
fi
if have netbird; then
  alias nbup='netbird up'
  alias nbdown='netbird down'
  alias nbs='netbird status'
fi

# ══ Git ═════════════════════════════════════════════════════
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate -20'

# ══ Docker (only if installed) ══════════════════════════════
if have docker; then
  alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias dpa='docker ps -a'
  alias dlogs='docker logs -f'
  alias dclean='docker system prune -f'
fi

# ══ Clipboard (Wayland) ═════════════════════════════════════
if have wl-copy; then
  alias copy='wl-copy'
  alias paste='wl-paste'
fi

# ══ Functions ═══════════════════════════════════════════════
# Fuzzy-pick a subfolder and cd into it (Esc cancels)
cdf() {
  local dir
  dir=$(find . -type d -not -path '*/.git*' 2>/dev/null | fzf) && cd "$dir"
}

# Make a folder and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Back up a file with a timestamp: bak file.conf
bak() { cp -v "$1" "$1.bak.$(date +%F_%H%M)"; }

# Extract any archive: extract file.tar.gz
extract() {
  [ -f "$1" ] || { echo "'$1' is not a file"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.zip)            unzip "$1" ;;
    *.7z)             7z x "$1" ;;
    *.rar)            unrar x "$1" ;;
    *) echo "don't know how to extract '$1'" ;;
  esac
}

# Is a host up? up <ip-or-hostname>
up() { command ping -c 1 -W 1 "$1" >/dev/null && echo "$1 is UP" || echo "$1 is DOWN"; }

# Check every homelab box at once
lab() {
  local h
  # Put your own hosts here (IPs or names from ~/.ssh/config)
  for h in router dns-server node1 node2 docker-vm; do
    up "$h"
  done
}
   # ══ My own prompt ══════════════════════════════════════════
   # Colors are 256-color numbers — run `colors` to see them all
   P_ERR_BG=131;  P_ERR_FG=255    # box when last command failed (soft brick red)
   P_USER_BG=238; P_USER_FG=250   # username box (dark gray)
   P_HOME_BG=24;  P_DIR_FG=254    # folder box when you are in ~ (deep blue)
   P_DIR_PALETTE=(30 60 66 95 101 137 67 96)  # soft colors for every other folder
   P_GIT_BG=136;  P_GIT_FG=230    # git branch box (muted gold)
   P_TIME_FG=245                  # clock text (soft gray)
   P_CHAR="🔥╚═══════❯";  P_CHAR_COLOR=108  # symbol before your cursor (sage green)
   P_SEP=$'\xee\x82\xb0'          # arrow between boxes
   P_GIT_ICON=$'\xee\x82\xa0'     # branch icon

   _seg() {  # usage: _seg BG FG TEXT
     [ -n "$_pbg" ] && _ps+="\[\e[38;5;${_pbg};48;5;$1m\]$P_SEP"
     _ps+="\[\e[48;5;$1;38;5;$2m\] $3 "
     _pbg=$1
   }

   _dircolor() {  # home = fixed color, every other folder = its own color
     if [ "$PWD" = "$HOME" ]; then
       echo "$P_HOME_BG"
     else
       local h; h=$(printf '%s' "$PWD" | cksum); h=${h%% *}
       echo "${P_DIR_PALETTE[$(( h % ${#P_DIR_PALETTE[@]} ))]}"
     fi
   }

   _myprompt() {
     local rc=$? branch
     _ps=""; _pbg=""
     [ "$rc" -ne 0 ] && _seg "$P_ERR_BG" "$P_ERR_FG" "✘ $rc"
     _seg "$P_USER_BG" "$P_USER_FG" "\u"
     _seg "$(_dircolor)" "$P_DIR_FG" "\w"
     branch=$(git branch --show-current 2>/dev/null)
     [ -n "$branch" ] && _seg "$P_GIT_BG" "$P_GIT_FG" "$P_GIT_ICON $branch"
     _ps+="\[\e[0;38;5;${_pbg}m\]$P_SEP\[\e[0m\]"
     PS1="$_ps \[\e[38;5;${P_TIME_FG}m\]\A\[\e[0m\]\n\[\e[38;5;${P_CHAR_COLOR}m\]$P_CHAR\[\e[0m\] "
   }
   PROMPT_COMMAND="_myprompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"
