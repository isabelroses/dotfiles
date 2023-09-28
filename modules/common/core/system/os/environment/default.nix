{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./locale.nix # locale settings
    ./display # display protocol (wayland/xorg)
  ];
  environment = {
    # variables that I want to set globally on all systems
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_PAGERSECURE = "true";
      PAGER = "less -FR";
      FLAKE = "${config.modules.system.flakePath}";
    };

    # packages I want on all systems
    systemPackages = with pkgs; [
      git
      curl
      wget
      pciutils
      lshw
    ];

    # disable all packages installed by default, so that my system doesn't have anything
    # that I myself have added
    defaultPackages = [];

    # enable completions for system packages
    pathsToLink = ["/share/fish" "/share/bash-completion" "/share/nix-direnv"];

    # https://github.com/NixOS/nixpkgs/issues/72394#issuecomment-549110501
    # why??
    etc."mdadm.conf".text = ''
      MAILADDR root
    '';
  };
}
