### EXPORT ###
set TERM "xterm-256color"
set fish_greeting
set TERMINAL "alacritty"
export "MICRO_TRUECOLOR=1"
export GPG_TTY=$(tty)

# Created by `pipx` on 2023-04-08 16:38:47
set PATH $PATH /home/isabel/.local/bin

# "bat" as manpager
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# ALIASES
# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# ls to exa
alias ls='exa -al --color=always --icons --group-directories-first'
alias la='exa -a --color=always --icons --group-directories-first'
alias ll='exa -abghHliS --icons --group-directories-first'
alias lt='exa -aT --color=always --icons --group-directories-first'
alias l.='exa -a | egrep "^\."'

# confirm
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

# always create pearent directory
alias mkidr='mkdir -pv'

# human readblity
alias df='df -h'

# pacman and yay
# alias pacsyu='sudo pacman -Syu'                  # update only standard pkgs
# alias pacsyyu='sudo pacman -Syyu'                # Refresh pkglist & update standard pkgs
# alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
# alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
# alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
# alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
# alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
# alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output (good for log files)
# alias grep='grep --color=auto'
# alias egrep='egrep --color=auto'
# alias fgrep='fgrep --color=auto'

# System
alias rs='sudo reboot'
alias sysctl='sudo systemctl'
alias doas='doas --'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# lazygit
alias lg="lazygit"

# PROMPT
# find out which distribution we are running on
set LFILE "/etc/os-release"
set MFILE "/System/Library/CoreServices/SystemVersion.plist"
set distro (awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

# set an icon based on the distro
switch $distro;
    case '*kali*'                       
      set ICON "ﴣ";
    case '*arch*'                       
      set ICON "";
    case '*debian*'                     
      set ICON "";
    case '*raspbian*'                   
      set ICON "";
    case '*ubuntu*'                     
      set ICON "";;
    case '*elementary*'                 
      set ICON "";
    case '*fedora*'                     
      set ICON "";
    case '*coreos*'                     
      set ICON "";
    case '*gentoo*'                     
      set ICON "";
    case '*mageia*'                     
      set ICON "";
    case '*centos*'                     
      set ICON "";
    case '*opensuse*' or '*tumbleweed*' 
      set ICON "";
    case '*sabayon*'                    
      set ICON "";
    case '*slackware*'                  
      set ICON "";
    case '*linuxmint*'                  
      set ICON "";
    case '*alpine*'                     
      set ICON "";
    case '*aosc*'                       
      set ICON "";
    case '*nixos*'                      
      set ICON "";
    case '*devuan*'                     
      set ICON "";
    case '*manjaro*'                    
      set ICON "";
    case '*rhel*'                       
      set ICON "";
    case '*macos*'                      
      set ICON "";
    case '*'                            
      set ICON "";
end

set -x STARSHIP_CONFIG "$HOME/.config/starship.toml"
set -x STARSHIP_DISTRO "$ICON $USER "

starship init fish | source
