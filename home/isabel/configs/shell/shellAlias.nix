{
  # This configuration creates the shell aliases across: bash, zsh and fish
  home.shellAliases = {
    mkdir = "mkdir -pv"; # always create pearent directory
    df = "df -h"; # human readblity
    rs = "sudo reboot";
    sysctl = "sudo systemctl";
    jctl = "journalctl -p 3 -xb"; # get error messages from journalctl
    lg = "lazygit";

    napbk = "cd ~/.local/share/nap ; git commit -am 'chore: sync changes'; git push ; cd -";

    # Remap docker to podman
    docker = "podman";
    docker-compose = "podman-compose";
  };
}
