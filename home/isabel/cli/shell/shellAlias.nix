{
  # This configuration creates the shell aliases across: bash, zsh and fish
  home.shellAliases = {
    mkdir = "mkdir -pv"; # always create pearent directory
    df = "df -h"; # human readblity
    rs = "systemctl reboot";
    jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
    lg = "lazygit";
  };
}
