{config, ...}: {
  # variables that I want to set globally on all systems

  environment = {
    # the below can be done for faster shell reponse time but it can break things, and it did
    # binsh = "${pkgs.dash}/bin/dash";

    variables = {
      EDITOR = "nvim";
      VISUAL = "vscodium";
      SUDO_EDITOR = "nvim";

      SYSTEMD_PAGERSECURE = "true";
      PAGER = "less -FR";
      MANPAGER = "nvim +Man!";

      FLAKE = "${config.modules.system.flakePath}";
    };
  };
}
