{pkgs, ...}: {
  # we need git for flakes
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    lfs.enable = true;
  };

  environment = {
    # needed packages for the installer
    systemPackages = with pkgs; [
      nixos-install-tools
      vim # we are not installing neovim here so we have a light dev environment
      netcat
    ];
  };
}
