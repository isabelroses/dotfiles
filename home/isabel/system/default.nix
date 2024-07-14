{
  imports = [
    ./docs.nix # documentation
    ./env.nix # environment variables
    ./fixes.nix # fixes for weird hm quirks
    ./gpg.nix # gpg agent settings
    ./ssh.nix # ssh agent settings
    ./xdg.nix # xdg settings
  ];
}
